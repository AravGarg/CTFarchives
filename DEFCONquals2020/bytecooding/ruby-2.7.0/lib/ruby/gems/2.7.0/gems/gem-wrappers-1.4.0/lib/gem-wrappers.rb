require 'rbconfig'
require 'gem-wrappers/environment'
require 'gem-wrappers/installer'

module GemWrappers
  class Exception < Gem::Exception ; end
  class NoWrapper < Exception ; end

  def self.environment
    @environment ||= GemWrappers::Environment.new
  end

  def self.installer
    @installer ||= GemWrappers::Installer.new(environment_file)
  end

  def self.install(executables)
    environment.ensure
    installer.ensure

    # gem executables
    executables.each do |executable|
      installer.install(executable)
    end

    ruby_executables.each do |executable|
      installer.install(executable)
    end
  end

  def self.uninstall(executables)
    # gem executables
    executables.each do |executable|
      installer.uninstall(executable)
    end
  end

  def self.wrappers_path
    installer.wrappers_path
  end

  def self.wrapper_path(exe)
    file = File.join(wrappers_path, exe)
    if executable?(file)
      file
    else
      raise GemWrappers::NoWrapper, "No wrapper: #{file}"
    end
  end

  def self.installed_wrappers
    executables_in_directory(wrappers_path).sort.uniq
  end

  def self.gems_executables
    # do not use map(&:...) - for ruby 1.8.6 compatibility
    @executables ||= GemWrappers::Specification.installed_gems.map{|gem| gem.executables }.inject{|sum, n| sum + n }.uniq || []
  end

  def self.environment_file
    environment.file_name
  end

  def self.ruby_executables
    executables_in_directory(RbConfig::CONFIG["bindir"].sub(/\/+\z/, ''))
  end
  private_class_method :ruby_executables

  def self.executables_in_directory(dir)
    Dir.entries(dir).select do |file|
      executable?(File.join(dir, file))
    end
  end
  private_class_method :executables_in_directory

  def self.executable?(path)
    !File.directory?(path) && File.executable?(path)
  end
  private_class_method :executable?
end
