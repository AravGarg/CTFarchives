require 'rubygems/command_manager'
require 'rubygems/installer'
require 'rubygems/version'
require 'gem-wrappers'
require 'gem-wrappers/specification'

class WrappersCommand < Gem::Command
  def initialize
    super 'regenerate_binstubs', 'Re run generation of environment wrappers for gems.'
  end

  def arguments # :nodoc:
    "regenerate        regenerate environment wrappers for current Gem.home"
  end

  def usage # :nodoc:
    "#{program_name} [regenerate]"
  end

  def defaults_str # :nodoc:
    ""
  end

  def description # :nodoc:
    <<-DOC
Show (default) or regenerate environment wrappers for current 'GEM_HOME'.
DOC
  end

  def execute
    args = options[:args] || []
    subcommand = args.shift || ''
    case subcommand
    when '', 'show'
      args.empty? ? execute_show : execute_show_path(args.first)
    when 'regenerate'
      execute_regenerate(args)
    when FileExist
      execute_regenerate([File.expand_path(subcommand)])
    else
      execute_unknown subcommand
    end
  end

  def execute_show_path(exe)
    $stdout.puts gem_wrappers.wrapper_path(exe)
  end

  def execute_show
    list = gem_wrappers.installed_wrappers
    $stdout.puts description
    $stdout.puts "   Wrappers path: #{gem_wrappers.wrappers_path}"
    $stdout.puts "Environment file: #{gem_wrappers.environment_file}"
    $stdout.puts "     Executables: #{list.join(", ")}"
  end

  def execute_unknown(subcommand)
    $stderr.puts "Unknown wrapper subcommand: #{subcommand}"
    $stdout.puts description
    false
  end

  def execute_regenerate(list = [])
    list = gem_wrappers.gems_executables if list.empty?
    execute_show(list) if ENV['GEM_WRAPPERS_DEBUG']
    gem_wrappers.install(list)
  end

private

  def gem_wrappers
    @gem_wrappers ||= GemWrappers
  end
end

require 'gem-wrappers/command/file_exist'
