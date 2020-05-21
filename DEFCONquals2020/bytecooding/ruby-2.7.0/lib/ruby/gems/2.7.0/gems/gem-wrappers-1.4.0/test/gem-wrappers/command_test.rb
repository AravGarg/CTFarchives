require 'test_helper'
require 'pathname'
require 'tempfile'
require 'gem-wrappers/command'
require 'gem-wrappers/fakes'

describe WrappersCommand do
  subject do
    WrappersCommand.new
  end

  let(:gems) { %w[rake ruby] }

  before do
    @fake_wrappers = GemWrappers::Fake.new(gems)
    subject.instance_variable_set(:@gem_wrappers, @fake_wrappers)
    $stdout = StringIO.new
    $stderr = StringIO.new
  end

  after do
    $stdout = STDOUT
    $stderr = STDERR
  end

  it "has some strings" do
    subject.arguments.class.must_equal(String)
    subject.usage.class.must_equal(String)
    subject.defaults_str.class.must_equal(String)
    subject.description.class.must_equal(String)
    subject.program_name.class.must_equal(String)
  end

  it "shows help on unknown command" do
    subject.options[:args] = ['wrong']
    subject.execute
    $stderr.string.must_equal("Unknown wrapper subcommand: wrong\n")
    $stdout.string.must_equal(subject.description)
  end

  it "does show" do
    subject.options[:args] = ["show"]
    subject.execute

    $stderr.string.must_equal("")
    $stdout.string.must_match(%r{\
#{Regexp.escape(subject.description.strip)}
   Wrappers path: /path/to/wrappers
Environment file: /path/to/environment
     Executables: rake, ruby
})
  end

  it "does show rake" do
    subject.options[:args] = ["show", "rake"]
    subject.execute

    $stderr.string.must_equal("")
    $stdout.string.must_equal("/path/to/wrappers/rake\n")
  end

  it "regenerates wrappers" do
    subject.options[:args] = %w{regenerate rake}
    subject.execute
    @fake_wrappers.executables.must_equal(%w{rake})
  end

  describe "script wrappers" do
    before do
      @file = Tempfile.new('command-wrappers')
    end

    after do
      @file.close
      @file.unlink
    end

    it "generates script wrapper full path" do
      subject.options[:args] = [@file.path]
      subject.execute
      @fake_wrappers.executables.must_equal([@file.path])
    end

    it "generates script wrapper relative" do
      Dir.chdir(File.dirname(@file.path)) do
        subject.options[:args] = [File.basename(@file.path)]
        subject.execute
        @fake_wrappers.executables.must_equal([Pathname.new(@file.path).realpath.to_s])
      end
    end
  end
end
