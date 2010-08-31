module Beet
  module Rails
    # Make an entry in Rails routing file conifg/routes.rb
    #
    # === Example
    #
    #   route "map.root :controller => :welcome"
    #
    def route(routing_code)
      log 'route', routing_code
      sentinel = 'ActionController::Routing::Routes.draw do |map|'

      in_root do
        gsub_file 'config/routes.rb', /(#{Regexp.escape(sentinel)})/mi do |match|
          "#{match}\n  #{routing_code}\n"
        end
      end
    end

    # Add Rails to /vendor/rails
    #
    # ==== Example
    #
    #   freeze!
    #
    def freeze!(args = {})
      log 'vendor', 'rails edge'
      in_root { run('rake rails:freeze:edge', false) }
    end

    # Install a plugin.  You must provide either a Subversion url or Git url.
    # For a Git-hosted plugin, you can specify if it should be added as a submodule instead of cloned.
    #
    # ==== Examples
    #
    #   plugin 'restful-authentication', :git => 'git://github.com/technoweenie/restful-authentication.git'
    #   plugin 'restful-authentication', :git => 'git://github.com/technoweenie/restful-authentication.git', :submodule => true
    #   plugin 'restful-authentication', :svn => 'svn://svnhub.com/technoweenie/restful-authentication/trunk'
    #
    def plugin(name, options)
      log 'plugin', name

      if options[:git] && options[:submodule]
        in_root do
          Git.run("submodule add #{options[:git]} vendor/plugins/#{name}")
        end
      elsif options[:git] || options[:svn]
        in_root do
          run_ruby_script("script/plugin install #{options[:svn] || options[:git]}", false)
        end
      else
        log "! no git or svn provided for #{name}.  skipping..."
      end
    end

    def gem_group(group)
      @_gem_group = group
      yield
      @_gem_group = nil
    end

    # TODO prevent same gem from being added twice
    # Passes gem info along to gemfile method that handles adding it in
    def gem(name, options = {})
      log 'gem', name
      group = options.delete(:group) || @_gem_group
      version = options.delete(:version)

      gems_code = "gem '#{name}'"
      gems_code << ", '#{version}'" if version

      if options.any?
        opts = options.inject([]) {|result, h| result << [":#{h[0]} => #{h[1].inspect.gsub('"',"'")}"] }.sort.join(", ")
        gems_code << ", #{opts}"
      end

      gemfile(gems_code, :group => group)
    end

    # Adds a line inside the Gemfile. Used by #gem
    # If options :group is specified, the line is added inside the corresponding group
    def gemfile(data, options={})
      if group = options[:group]
        if group.is_a?(Array)
          group.each do |g|
            add_after_or_append "Gemfile", "group :#{g} do", "\s\s" + data, "group :#{g} do", "end\n"
          end
        else
          add_after_or_append "Gemfile", "group :#{group} do", "\s\s" + data, "group :#{group} do", "end\n"
        end
      else
        append_file "Gemfile", data
      end
    end

    # Adds a line inside the Initializer block for config/environment.rb.
    # If options :env is specified, the line is appended to the corresponding
    # file in config/environments/#{env}.rb
    def environment(data = nil, options = {}, &block)
      sentinel = 'Rails::Initializer.run do |config|'

      data = block.call if !data && block_given?

      in_root do
        if options[:env].nil?
          gsub_file 'config/environment.rb', /(#{Regexp.escape(sentinel)})/mi do |match|
            "#{match}\n  " << data
          end
        else
          Array.wrap(options[:env]).each do|env|
            append_file "config/environments/#{env}.rb", "\n#{data}"
          end
        end
      end
    end

    # Create a new file in the vendor/ directory. Code can be specified
    # in a block or a data string can be given.
    #
    # ==== Examples
    #
    #   vendor("sekrit.rb") do
    #     sekrit_salt = "#{Time.now}--#{3.years.ago}--#{rand}--"
    #     "salt = '#{sekrit_salt}'"
    #   end
    #
    #   vendor("foreign.rb", "# Foreign code is fun")
    #
    def vendor(filename, data = nil, &block)
      log 'vendoring', filename
      file("vendor/#{filename}", data, false, &block)
    end


    # Create a new initializer with the provided code (either in a block or a string).
    #
    # ==== Examples
    #
    #   initializer("globals.rb") do
    #     data = ""
    #
    #     ['MY_WORK', 'ADMINS', 'BEST_COMPANY_EVAR'].each do
    #       data << "#{const} = :entp"
    #     end
    #
    #     data
    #   end
    #
    #   initializer("api.rb", "API_KEY = '123456'")
    #
    def initializer(filename, data = nil, &block)
      log 'initializer', filename
      file("config/initializers/#{filename}", data, false, &block)
    end

    # Generate something using a generator from Rails or a plugin.
    # The second parameter is the argument string that is passed to
    # the generator or an Array that is joined.
    #
    # ==== Example
    #
    #   generate(:authenticated, "user session")
    #
    def generate(what, *args)
      log 'generating', what
      argument = args.map {|arg| arg.to_s }.flatten.join(" ")

      in_root { run_ruby_script("script/rails generate #{what} #{argument}", false) }
    end
  end # Rails
end # Beet
