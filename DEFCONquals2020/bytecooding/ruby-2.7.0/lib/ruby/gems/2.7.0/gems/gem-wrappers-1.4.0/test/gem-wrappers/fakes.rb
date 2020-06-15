module GemWrappers
  class FakeInstaller
    def initialize
      @executables = []
    end
    def install(executable)
      @executables << executable
    end
    def uninstall(executable)
      @executables.delete(executable)
    end
    def executables
      @executables.uniq
    end
    def ensure
      @ensure = true
    end
    def ensure?
      @ensure
    end
    def wrappers_path
      "/path/to/wrappers"
    end
  end
  class FakeEnvironment
    def ensure
      @ensure = true
    end
    def ensure?
      @ensure
    end
    def file_name
      "/path/to/environment"
    end
  end
  class Fake
    def initialize(gems)
      @gems = gems
      @executables = []
    end
    def install(executables)
      @executables += executables
    end
    def uninstall(executables)
      @executables -= executables
    end
    def executables
      @executables
    end
    def environment_file
      "/path/to/environment"
    end
    def wrappers_path
      "/path/to/wrappers"
    end
    def wrapper_path(exe)
      file = File.join(wrappers_path, exe)
      if @gems.include?(exe)
        file
      else
        raise GemWrappers::NoWrapper, "No wrapper: #{file}"
      end
    end
    def installed_wrappers
      @gems
    end
    def gems_executables
      @gems
    end
  end
end
