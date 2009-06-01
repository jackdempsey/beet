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
    attr_accessor :recipes, :project_name, :gems

    def initialize(project_name, options={}) # :nodoc:
      @root = if File.exists?(root = File.join(Dir.pwd, project_name))
                root
              elsif project_name.include?('/')
                File.dirname(project_name)
              else
                Dir.pwd
              end
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
      @recipes = []
      if options[:recipes]
        options[:recipes].split(/[\s,]+/).each do |recipe|
          if file = recipe_location(recipe)
            @recipes << file
          end
        end
      end
    end

    def start
      run_recipes
      add_gems
    end

    def run_recipes
      if @recipes.empty?
        puts "No recipes found."
      else
        @recipes.each do |recipe|
          begin
            code = open(recipe).read
            in_root { self.instance_eval(code) }
          rescue LoadError, Errno::ENOENT => e
            raise "The recipe [#{recipe}] could not be loaded. Error: #{e}"
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

    def recipe_location(recipe)
      return recipe if File.exists?(recipe) or recipe.include?('http://')
      locations = []
      locations << File.expand_path(ENV['BEET_RECIPES_DIR']) if ENV['BEET_RECIPES_DIR']
      locations << File.expand_path(File.join(File.dirname(__FILE__), 'recipes'))
      locations.each do |location|
        filename = File.join(location, "#{recipe}.rb")
        return filename if File.exists?(filename)
      end
      nil
    end
  end
end
