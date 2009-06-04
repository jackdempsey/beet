require 'test_helper'

class ExecutorShouldaTest < Test::Unit::TestCase

  should "set project root to Dir.pwd + project_name in general case" do
    executor = Beet::Executor.new('foobar')
    assert_equal Dir.pwd + "/foobar", executor.root
  end

  should "set project root to project name if project name looks like /Users/jack/something" do
    executor = Beet::Executor.new('/Users/jack/foobar')
    assert_equal '/Users/jack/foobar', executor.root
  end

  should "set project root to Dir.pwd if directory one level above is the same as the project name" do
    FileUtils.mkdir_p 'foobar'
    FileUtils.chdir 'foobar' do 
      executor = Beet::Executor.new('foobar')
      assert_equal Dir.pwd, executor.root
    end
    FileUtils.rm_rf 'foobar'
  end

end
