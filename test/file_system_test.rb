require 'test_helper'

include Beet::FileSystem

# define some methods that file_system recipes expect to exist
def root; '.'; end
class FileSystemTest < Test::Unit::TestCase
  context "#add_after" do
    setup do
      @filename = 'test.file'
      File.open(@filename,'w') do |f|
        f.puts "first line"
        f.puts "second line"
      end
    end

    teardown do
      File.unlink(@filename)
    end

    should "add the given text after the specified text" do
      add_after @filename, "first line", "middle line" 
      assert_equal "first line\nmiddle line\nsecond line\n", File.read(@filename)
    end

    should "not add the given text if it already exists after the specified text" do
      add_after @filename, "first line", "middle line" 
      assert_equal "first line\nmiddle line\nsecond line\n", File.read(@filename)
      add_after @filename, "first line", "middle line" 
      assert_equal "first line\nmiddle line\nsecond line\n", File.read(@filename)
    end

    should "add the given text if it exists but only elsewhere in the specified text" do
      add_after @filename, "first line", "middle line"
      assert_equal "first line\nmiddle line\nsecond line\n", File.read(@filename)
      add_after @filename, "first line", "second line"
      assert_equal "first line\nsecond line\nmiddle line\nsecond line\n", File.read(@filename)
    end
  end

  context "#append_file" do
    setup do
      @filename = 'test.file'
      File.open(@filename,'w') do |f|
        f.puts "first line"
        f.puts "second line"
      end
    end

    teardown do
      File.unlink(@filename)
    end

    should "add text to the end of the file" do
      append_file @filename, "third line"
      assert_equal "first line\nsecond line\nthird line", File.read(@filename)
    end
  end
end
