require 'fileutils'
module Beet
  module FileSystem
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

    # Run a regular expression replacement on a file
    #
    # ==== Example
    #
    #   gsub_file 'app/controllers/application_controller.rb', /#\s*(filter_parameter_logging :password)/, '\1'
    #
    def gsub_file(relative_destination, regexp, *args, &block)
      #path = destination_path(relative_destination)
      path = relative_destination
      content = File.read(path)
      check_for = args.first || yield('')
      regex = Regexp.new(regexp.source + Regexp.escape(check_for))
      return if content =~ regex # if we can match the text and its leadin regex, don't add again
      content = content.gsub(regexp, *args, &block)
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

    # Add text after matching line
    #
    # ==== Example
    #
    #    add_after 'config/environment.rb', '# config.gem "aws-s3", :lib => "aws/s3"'
    #
    def add_after(filename, matching_text, data=nil, &block)
      gsub_file filename, /(\s*#{Regexp.escape(matching_text)})/mi do |match|
        "#{match}\n#{data || block.call}"
      end
    end

    # Add text before matching line
    #
    # ==== Example
    #
    #    add_before 'config/environment.rb', '# config.gem "aws-s3", :lib => "aws/s3"'
    #
    def add_before(filename, matching_text, data=nil, &block)
      gsub_file filename, /^(\s*#{Regexp.escape(matching_text)})/mi do |match|
        "#{data || block.call}#{match}"
      end
    end

    protected

    def destination_path(relative_destination)
      File.join(root, relative_destination)
    end

  end
end
