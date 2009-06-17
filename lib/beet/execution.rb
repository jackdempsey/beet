module Beet
  module Execution
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
      system(command)
    end

    # Executes a command with sudo
    #
    # ==== Example
    #
    #   inside('vendor') do
    #     sudo('mkdir /var/log/something')
    #   end
    #
    def sudo(command, log_action = true)
      command = "#{SUDO}#{command}"
      run(command,log_action)
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
  end
end
