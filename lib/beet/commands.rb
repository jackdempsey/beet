require File.dirname(__FILE__) + '/scm/scm'
require File.dirname(__FILE__) + '/scm/git'
require File.dirname(__FILE__) + '/scm/svn'

require 'open-uri'
require 'fileutils'

module Beet
  module Commands
    # Create a new file in the project folder.  Specify the
    # relative path from the project's root.  Data is the return value of a block
    # or a data string.
    #
    # ==== Examples
    #
    #   file("lib/fun_party.rb") do
    #     hostname = ask("What is the virtual hostname I should use?")
    #     "vhost.name = #{hostname}"
    #   end
    #
    #   file("config/apach.conf", "your apache config")
    #
    def file(filename, data = nil, log_action = true, &block)
      log 'file', filename if log_action
      dir, file = [File.dirname(filename), File.basename(filename)]

      inside(dir) do
        File.open(file, "w") do |f|
          if block_given?
            f.write(block.call)
          else
            f.write(data)
          end
        end
      end
    end


    # Create a new file in the lib/ directory. Code can be specified
    # in a block or a data string can be given.
    #
    # ==== Examples
    #
    #   lib("crypto.rb") do
    #     "crypted_special_value = '#{rand}--#{Time.now}--#{rand(1337)}--'"
    #   end
    #
    #   lib("foreign.rb", "# Foreign code is fun")
    #
    def lib(filename, data = nil, &block)
      log 'lib', filename
      file("lib/#{filename}", data, false, &block)
    end

    # Create a new Rakefile with the provided code (either in a block or a string).
    #
    # ==== Examples
    #
    #   rakefile("bootstrap.rake") do
    #     project = ask("What is the UNIX name of your project?")
    #
    #     <<-TASK
    #       namespace :#{project} do
    #         task :bootstrap do
    #           puts "i like boots!"
    #         end
    #       end
    #     TASK
    #   end
    #
    #   rakefile("seed.rake", "puts 'im plantin ur seedz'")
    #
    def rakefile(filename, data = nil, &block)
      log 'rakefile', filename
      file("lib/tasks/#{filename}", data, false, &block)
    end

    # Executes a command
    #
    # ==== Example
    #
    #   inside('vendor') do
    #     run('ln -s ~/edge rails)
    #   end
    #
    def run(command, log_action = true)
      log 'executing',  "#{command} from #{Dir.pwd}" if log_action
      `#{command}`
    end

    # Executes a ruby script (taking into account WIN32 platform quirks)
    def run_ruby_script(command, log_action = true)
      ruby_command = RUBY_PLATFORM=~ /win32/ ? 'ruby ' : ''
      run("#{ruby_command}#{command}", log_action)
    end

    # Runs the supplied rake task
    #
    # ==== Example
    #
    #   rake("db:migrate")
    #   rake("db:migrate", :env => "production")
    #   rake("gems:install", :sudo => true)
    #
    def rake(command, options = {})
      log 'rake', command
      env = options[:env] || 'development'
      sudo = options[:sudo] ? 'sudo ' : ''
      in_root { run("#{sudo}rake #{command} RAILS_ENV=#{env}", false) }
    end

    protected

    # Get a user's input
    #
    # ==== Example
    #
    #   answer = ask("Should I freeze the latest Rails?")
    #   freeze! if ask("Should I freeze the latest Rails?") == "yes"
    #
    def ask(string)
      log '', string
      STDIN.gets.strip
    end

    # Do something in the root of the project or
    # a provided subfolder; the full path is yielded to the block you provide.
    # The path is set back to the previous path when the method exits.
    def inside(dir = '', &block)
      folder = File.join(root, dir)
      FileUtils.mkdir_p(folder) unless File.exist?(folder)
      FileUtils.cd(folder) { block.arity == 1 ? yield(folder) : yield }
    end

    def in_root
      FileUtils.cd(root) { yield }
    end

    # Helper to test if the user says yes(y)?
    #
    # ==== Example
    #
    #   freeze! if yes?("Should I freeze the latest Rails?")
    #
    def yes?(question)
      answer = ask(question).downcase
      answer == "y" || answer == "yes"
    end

    # Helper to test if the user does NOT say yes(y)?
    #
    # ==== Example
    #
    #   capify! if no?("Will you be using vlad to deploy your application?")
    #
    def no?(question)
      !yes?(question)
    end

    # Run a regular expression replacement on a file
    #
    # ==== Example
    #
    #   gsub_file 'app/controllers/application_controller.rb', /#\s*(filter_parameter_logging :password)/, '\1'
    #
    def gsub_file(relative_destination, regexp, *args, &block)
      path = destination_path(relative_destination)
      content = File.read(path).gsub(regexp, *args, &block)
      File.open(path, 'wb') { |file| file.write(content) }
    end

    # Append text to a file
    #
    # ==== Example
    #
    #   append_file 'config/environments/test.rb', 'config.gem "rspec"'
    #
    def append_file(relative_destination, data)
      path = destination_path(relative_destination)
      File.open(path, 'ab') { |file| file.write(data) }
    end

    def destination_path(relative_destination)
      File.join(root, relative_destination)
    end

    def log(action, message = '')
      logger.log(action, message)
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end

  end
end
