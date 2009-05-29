require 'open-uri'
require 'beet/logger'
module Beet
  class Executor
    include Beet::Execution
    include Beet::FileSystem
    include Beet::Interaction

    # TODO create a better way to mixin things from rails/whatever as needed
    include Beet::Rails
    include Beet::Capistrano
    include Beet::SCM

    attr_reader :root, :logger
    attr_accessor :templates, :project_name, :gems

    def initialize(project_name, options) # :nodoc:
      @root = File.expand_path(File.join(Dir.pwd, project_name))
      @project_name = project_name == '.' ? File.basename(Dir.pwd) : project_name
      @logger = Beet::Logger.new
      @gems = []
      if options[:gems]
        options[:gems].split(/[\s,]+/).each do |gem|
          if location = gem_location(gem)
            @gems << {:name => gem, :source => location}
          else
            puts "gem: #{gem} not found. Did you spell it correctly? If so, submit a patch with its location!"
          end
        end
      end
      @templates = []
      if options[:templates]
        options[:templates].split(/[\s,]+/).each do |template|
          if file = template_location(template)
            @templates << file
          end
        end
      end
    end

    def start
      run_templates
      add_gems
    end

    def run_templates
      if @templates.empty?
        puts "No templates found."
      else
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

    def add_gems
      if @gems
        @gems.each do |gem_data|
          gem(gem_data[:name], :source => gem_data[:source])
        end
      end
    end

    def log(*args)
      logger.log(*args)
    end

    private

    def gem_location(gem_name)
      GEM_LOCATIONS[gem_name]
    end

    def template_location(template)
      return template if File.exists?(template) or template.include?('http://')
      locations = []
      locations << File.expand_path(ENV['BEET_TEMPLATES_DIR']) if ENV['BEET_TEMPLATES_DIR']
      locations << File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
      locations.each do |location|
        filename = File.join(location, "#{template}.rb")
        return filename if File.exists?(filename)
      end
      nil
    end
  end
end
