["./tmp/pids", "./tmp/sessions", "./tmp/sockets", "./tmp/cache"].each do |f|
  run("rmdir ./#{f}")
end

run("find . \\( -type d -empty \\) -and \\( -not -regex ./\\.git.* \\) -exec touch {}/.gitignore \\;")

git :init

file '.gitignore', <<-CODE
log/\\*.log
log/\\*.pid
db/\\*.db
db/\\*.sqlite3
db/schema.rb
tmp/\\*\\*/\\*
.DS_Store
doc/api
doc/app
config/database.yml
CODE

git :add => "."

git :commit => "-m 'Initial commit. Enjoy.'"
