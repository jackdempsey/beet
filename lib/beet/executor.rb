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
    include Beet::SCM

    attr_reader :root
    attr_writer :logger
    attr_accessor :templates, :app_name

    def initialize(templates, app_name) # :nodoc:
      @root = File.expand_path(File.join(Dir.pwd, app_name))
      @templates = []
      templates.split(/[\s,]+/).each do |template|
        if file = template_location(template)
          @templates << file
        end
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

    private

    def template_location(template)
      return template if File.exists?(template) or template.include?('http://')
      locations = []
      locations << File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
      locations << File.expand_path(ENV['BEET_TEMPLATES_DIR']) if ENV['BEET_TEMPLATES_DIR']
      locations.each do |location|
        filename = File.join(location, "#{template}.rb")
        return filename if File.exists?(filename)
      end
    end
  end
end
