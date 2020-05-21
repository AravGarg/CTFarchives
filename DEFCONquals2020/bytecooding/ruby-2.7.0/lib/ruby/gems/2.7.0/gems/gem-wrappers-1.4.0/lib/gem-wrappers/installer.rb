require 'erb'
require 'fileutils'

module GemWrappers
  class Installer
    attr_reader :environment_file

    def initialize(environment_file = nil, executable_format = Gem.default_exec_format)
      @environment_file = environment_file
      @executable_format = executable_format
    end

    def self.wrappers_path
      Gem.configuration && Gem.configuration[:wrappers_path] ||
      File.join(Gem.dir, 'wrappers')
    end

    def wrappers_path
      @wrappers_path ||= self.class.wrappers_path
    end

    def ensure
      FileUtils.mkdir_p(wrappers_path) unless File.exist?(wrappers_path)
      # exception based on Gem::Installer.generate_bin
      unless File.writable?(wrappers_path)
        raise Gem::FilePermissionError.new(wrappers_path)
      end
      unless @environment_file
        raise "Missing environment file for initialize!"
      end
    end

    def uninstall(executable)
      file_name = File.join(wrappers_path, executable)
      File.delete(file_name) if File.exist?(file_name)
    end

    def install(executable)
      target_path = find_executable_path(executable)
      unless target_path
        warn "GemWrappers: Can not wrap missing file: #{executable}"
        return
      end
      unless File.executable?(target_path)
        warn "GemWrappers: Can not wrap not executable file: #{target_path}"
        return
      end
      @executable = executable
      content = ERB.new(template).result(binding)
      install_file(executable, content)
      install_to_formatted(executable, content)
    end

    def find_executable_path(executable)
      return executable if File.exist?(executable)
      ENV['PATH'].split(File::PATH_SEPARATOR).each { |dir|
        full_path = File.join(dir, executable)
        return full_path if File.exist?(full_path)
      }
      nil
    end

    def install_to_formatted(executable, content)
      formatted_executable = @executable_format % executable
      if
        formatted_executable != executable
      then
        install_file(formatted_executable, content)
      end
    end

    def install_file(executable, content)
      file_name = File.join(wrappers_path, File.basename(executable))
      File.open(file_name, 'w') do |file|
        file.write(content)
      end
      file_set_executable(file_name)
    end

    def executable_expanded
      if File.extname(@executable) == ".rb"
      then "ruby #{@executable}"
      else @executable
      end
    end

    def template
      @template ||= <<-TEMPLATE
#!/usr/bin/env bash

if
  [[ -s "<%= environment_file %>" ]]
then
  source "<%= environment_file %>"
  exec <%= executable_expanded %> "$@"
else
  echo "ERROR: Missing RVM environment file: '<%= environment_file %>'" >&2
  exit 1
fi
TEMPLATE
    end

  private
    def file_set_executable(file_name)
      stat = File.stat(file_name)
      File.chmod(stat.mode|0111, file_name) unless stat.mode&0111 == 0111
    end

  end
end
