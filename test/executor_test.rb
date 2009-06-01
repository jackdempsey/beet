require 'test_helper'

class ExecutorShouldaTest < Test::Unit::TestCase

  should "set project root to current directory if name given is not a folder" do
    executor = Beet::Executor.new('foobar')
    assert_equal Dir.pwd, executor.root
  end

  should "set project root to directory name if project name looks like /Users/jack/something" do
    executor = Beet::Executor.new('/Users/jack/foobar')
    assert_equal '/Users/jack', executor.root
  end

end
