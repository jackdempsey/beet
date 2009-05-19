# Just run the capify command in root
#
# ==== Example
#
#   capify!
#
def capify!
  log 'capifying'
  in_root { run('capify .', false) }
end
