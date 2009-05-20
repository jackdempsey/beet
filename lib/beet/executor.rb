require 'open-uri'
module Beet
  class Executor
    include Beet::Execution
    include Beet::FileSystem
    include Beet::Interaction
    include Beet::Logging

    attr_reader :root
    attr_writer :logger
    attr_accessor :template, :app_name

    def initialize(template, app_name) # :nodoc:
      @root = File.expand_path(File.join(Dir.pwd, app_name))
      puts "root is #{@root}"
      @template = template
    end

    def run_template
      begin
        code = open(@template).read
        in_root { self.instance_eval(code) }
      rescue LoadError, Errno::ENOENT => e
        raise "The template [#{template}] could not be loaded. Error: #{e}"
      end
    end

  end
end
