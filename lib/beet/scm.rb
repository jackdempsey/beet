class Scm

  private

  def self.hash_to_parameters(hash)
    hash.collect { |key, value| "--#{key} #{(value.kind_of?(String) ? value : "")}"}.join(" ")
  end
end
require File.dirname(__FILE__) + '/scm/git'
require File.dirname(__FILE__) + '/scm/svn'

module Beet
  module SCM
    # Run a command in git.
    #
    # ==== Examples
    #
    #   git :init
    #   git :add => "this.file that.rb"
    #   git :add => "onefile.rb", :rm => "badfile.cxx"
    #
    def git(command = {})
      in_root do
        if command.is_a?(Symbol)
          log 'running', "git #{command}"
          Git.run(command.to_s)
        else
          command.each do |command, options|
            log 'running', "git #{command} #{options}"
            Git.run("#{command} #{options}")
          end
        end
      end
    end
  end
end
