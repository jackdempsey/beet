require 'rubygems'
require 'test/unit'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'beet'
if RUBY_VERSION <= '1.8.6'
require 'ruby-debug'
end
class Test::Unit::TestCase
end
