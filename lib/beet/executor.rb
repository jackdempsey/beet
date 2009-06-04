require 'open-uri'
require 'beet/logger'
module Beet
  class Executor
    BEET_DATA_FILE = "~/.beet.yml"
    include Beet::Execution
    include Beet::FileSystem
    include Beet::Interaction

    include Beet::Rails
    include Beet::Capistrano
    include Beet::SCM

    attr_reader :root, :logger, :options, :template
    attr_accessor :recipes, :project_name, :gems

    def initialize(project_name, options={}) # :nodoc:
      @root = calculate_project_root(project_name)
      @project_name = project_name == '.' ? File.basename(Dir.pwd) : project_name
      @logger = Beet::Logger.new
      @gems = []
      @template = options[:template]
      @options = options
      @recipes = []
      @project_type = options[:project_type]
      @generate = true unless options[:generate] == false
      extract_commands_from_options
    end

    def start
      if @options[:use]
        puts "Loading saved configuration: #{@options[:use]}"
        data = load_saved_recipe_file
        if config = data[@options[:use]]
          @gems.concat(config[:gems]) if config[:gems]
          @template = config[:template] if config[:template]
          @recipes.concat(config[:recipes]) if config[:recipes]
        end
      end

      case @project_type
      when :rails
        if @generate
          puts "Generating rails project #{project_name}..."
          if @options[:template]
            system("rails #{project_name} -m #{TEMPLATE_LOCATIONS[options[:template]]}")
          else
            system("rails #{project_name}")
          end
        end
      end

      run_recipes
      add_gems

      if @options[:save]
        save_run
      end
    end

    def run_recipes
      @recipes.each do |recipe|
        begin
          code = open(recipe).read
          in_root { self.instance_eval(code) }
        rescue LoadError, Errno::ENOENT => e
          raise "The recipe [#{recipe}] could not be loaded. Error: #{e}"
        end
      end
    end

    def log(*args)
      logger.log(*args)
    end

    private

    def calculate_project_root(project_name)
      # if the name looks like ~/projects/foobar then thats the root
      if project_name.include?('/')
        project_name
      # if we're running inside the app, then current dir is it
      elsif File.basename(Dir.pwd) == project_name
        Dir.pwd
      # assume the root is ./project_name
      else
        File.join(Dir.pwd, project_name)
      end
    end

    def add_gems
      if @gems
        @gems.each do |gem_data|
          gem(gem_data[:name], :source => gem_data[:source])
        end
      end
    end

    def extract_commands_from_options
      if @options[:gems]
        @options[:gems].split(/[\s,]+/).each do |gem|
          if location = gem_location(gem)
            @gems << {:name => gem, :source => location}
          else
            puts "gem: #{gem} not found. Did you spell it correctly? If so, submit a patch with its location!"
          end
        end
      end
      if @options[:recipes]
        @options[:recipes].split(/[\s,]+/).each do |recipe|
          if file = recipe_location(recipe)
            @recipes << file
          end
        end
      end
    end

    def save_run
      require 'yaml'
      name = if options[:save] == true
               ask("Enter a name for this configuration: ")
             else
               options[:save]
             end
      data = load_saved_recipe_file
      data[name] = {:gems => @gems, :recipes => @recipes, :template => @template}
      write_saved_recipe_file(data)
    end

    def beet_data_file
      File.expand_path(BEET_DATA_FILE)
    end

    def load_saved_recipe_file
      if File.exists?(beet_data_file)
        YAML.load_file(beet_data_file)
      else
        {}
      end
    end

    def write_saved_recipe_file(data)
      File.open(beet_data_file, "wb") do |f|
        f.write(YAML::dump(data))
      end
    end

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
