require 'open-uri'
module Beet
  class Executor
    include Beet::Execution
    include Beet::FileSystem
    include Beet::Interaction
    include Beet::Logging

    # TODO create a better way to mixin things from rails/whatever as needed
    include Beet::Rails
    include Beet::Capistrano
    include Beet::Scm

    attr_reader :root
    attr_writer :logger
    attr_accessor :templates, :app_name

    def initialize(templates, app_name) # :nodoc:
      @root = File.expand_path(File.join(Dir.pwd, app_name))
      @templates = []
      templates.split(/[\s,]+/).each do |template|
        @templates << (if !File.exists?(template) and !template.include?('http')
                        # they're trying to use a named template from the templates directory
                        File.expand_path(File.join(File.dirname(__FILE__), 'templates', "#{template}.rb"))
                      else
                        template
                      end)
      end
    end

    def run_templates
      @templates.each do |template|
        begin
          code = open(template).read
          in_root { self.instance_eval(code) }
        rescue LoadError, Errno::ENOENT => e
          raise "The template [#{template}] could not be loaded. Error: #{e}"
        end
      end
    end

  end
end
