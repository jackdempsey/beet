require 'open-uri'
require 'beet/logger'
require 'yaml'
require 'ruby-debug'

module Beet
  class Executor
    BEET_DATA_FILE = "~/.beet.yml"
    include Beet::CommandExecution
    include Beet::FileSystem
    include Beet::Interaction

    include Beet::Rails
    include Beet::Capistrano
    include Beet::SCM

    attr_reader :root, :logger, :options, :template
    attr_accessor :recipes, :project_name, :gems, :todo_items

    def initialize(project_name, options={}) # :nodoc:
      @root = calculate_project_root(project_name)
      @project_name = ((project_name == '.') ? File.basename(Dir.pwd) : project_name)
      @logger = Beet::Logger.new
      @gems = []
      @template = options[:template]
      @options = options
      @todo_items = ''
      @recipes = []
      @project_type = (options[:project_type] && options[:project_type].to_sym) || :rails3
      @generate = true unless options[:generate] == false
      @display = options[:display]
      extract_commands_from_options
    end

    def start
      if options[:use]
        puts "Loading saved configuration: #{@options[:use]}"
        data = load_saved_recipe_file
        if config = data[@options[:use]]
          @gems.concat(config[:gems]) if config[:gems]
          @template = config[:template] if config[:template]
          @recipes.concat(config[:recipes]) if config[:recipes]
        end
      end

      if @display && @template
        puts open(TEMPLATE_LOCATIONS[@template]).read
      else
        if @generate
          # TODO maybe let people specify path to rails 3 script rather than just assume its 'rails'
          if @project_type == :rails3
            puts "Generating rails 3 project #{project_name}..."
            if @template
              system("rails new #{project_name} -m #{TEMPLATE_LOCATIONS[@template]}")
            else
              system("rails new #{project_name}")
            end
          else
            puts "Generating rails project #{project_name}..."
            if @template
              system("rails #{project_name} -m #{TEMPLATE_LOCATIONS[@template]}")
            else
              system("rails #{project_name}")
            end
          end
        end

        add_gems

        print_todo

        if options[:save]
          save_run
        end
      end

      run_recipes

    end

    def run_recipes
      @recipes.each do |recipe|
        begin
          code = open(recipe).read
          if @display
            puts code
          else
            in_root { instance_eval(code)}
          end
        rescue LoadError, Errno::ENOENT => e
          raise "The recipe [#{recipe}] could not be loaded. Error: #{e}"
        end
      end
    end

    def log(*args)
      logger.log(*args)
    end

    def todo(string=nil, &block)
      self.todo_items << (string || block.call)
    end

    private

    def print_todo
      unless todo_items.empty?
        puts '#' * 30
        puts "TODO Items:"
        puts todo_items
        puts '#' * 30
      end
    end

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
          duped_data = gem_data.clone # to avoid removing :name from @gems
          name = duped_data.delete(:name)
          gem(name, duped_data)
        end
      end
    end

    def extract_commands_from_options
      if options[:gems]
        options[:gems].split(/[\s,]+/).each do |gem|
          if gem_info = gem_location(gem)
            if gem_info.is_a?(Hash)
              @gems << {:name => gem}.merge(gem_info)
            else
              @gems << {:name => gem, :source => gem_info}
            end
          else
            @gems << {:name => gem}
          end
        end
      end
      if options[:recipes]
        options[:recipes].split(/[\s,]+/).each do |recipe|
          if file = recipe_location(recipe)
            @recipes << file
          else
            puts "Can't find recipe #{recipe}"
          end
        end
      end
    end

    def save_run
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
        ::YAML.load_file(beet_data_file)
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

