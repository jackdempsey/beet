require File.dirname(__FILE__) + '/scm/scm'
require File.dirname(__FILE__) + '/scm/git'
require File.dirname(__FILE__) + '/scm/svn'

require 'open-uri'
require 'fileutils'

module Beet
  module Commands
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

    def log(action, message = '')
      logger.log(action, message)
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end

  end
end
