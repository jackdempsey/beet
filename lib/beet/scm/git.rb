class Git < Scm
  def self.clone(repos, branch=nil)
    `git clone #{repos}`

    if branch
      `cd #{repos.split('/').last}/`
      `git checkout #{branch}`
    end
  end

  def self.run(command)
    `git #{command}`
  end
end

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
