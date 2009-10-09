require File.dirname(__FILE__) + '/test_helper.rb'

class TestQer < Test::Unit::TestCase

  def setup
    @file = File.join(File.dirname(__FILE__), 'testqueue.tmp')
    File.delete(@file) if File.exists?(@file)
    @todo = Qer::ToDo.new(@file)
  end

  context "push" do
    setup do
      @todo.push("Some Task")
    end

    should "have one item" do
      assert_equal 1, @todo.size
    end

    should "have two items" do
      @todo.push("Some Other Task")
      assert_equal 2, @todo.size
    end
  end

  context "pop" do
    setup do
      @todo.push("Some Task")
      @todo.push("Some Other Task")
      @item = @todo.pop
    end

    should "pop the right item" do
      assert_equal "Some Other Task", @item[1]
    end

    should "have one item" do
      assert_equal 1, @todo.size
    end
  end

  context "add" do
    setup do
      @todo.add("Some Task")
    end

    should "have one item" do
      assert_equal 1, @todo.size
    end

    should "have two items" do
      @todo.add("Some Other Task")
      assert_equal 2, @todo.size
    end
  end

  context "remove" do
    setup do
      @todo.add("Some Task")
      @todo.add("Some Other Task")
      @item = @todo.remove(0)
    end

    should "remove the right item" do
      assert_equal "Some Task", @item[1]
    end

    should "have one item" do
      assert_equal 1, @todo.size
    end
  end

  context "clear" do
    setup do
      @todo.add("Some Task")
      @todo.add("Some Other Task")
      @todo.clear
    end

    should "have one item" do
      assert_equal 0, @todo.size
    end
  end

  context "read" do
    setup do
      @file = File.join(File.dirname(__FILE__), 'test_queue')
      @todo = Qer::ToDo.new(@file)
    end

    should "have 5 items" do
      assert_equal 5, @todo.size
    end
  end

  context "write" do
    setup do
      @todo.add("Some Task")
      @todo.add("Some Other Task")
      @other_todo = Qer::ToDo.new(@file)
    end

    should "have 2 items" do
      assert_equal 2, @todo.size
    end
  end

  context "command" do
    setup do
      @todo.add("Some Task")
    end

    should "add" do
      @todo.command(%w(add some stuff))
      assert_equal 2, @todo.size
    end

    should "remove" do
      assert_equal "Some Task", @todo.command(%w(remove 0)).last
      assert_equal 0, @todo.size
    end

    should "push" do
      @todo.command(%w(push some stuff))
      assert_equal 2, @todo.size
    end

    should "pop" do
      assert_equal "Some Task", @todo.command(%w(pop)).last
      assert_equal 0, @todo.size
    end

    should "clear" do
      @todo.command(%w(clear))
      assert_equal 0, @todo.size
    end

    should "help" do
      @todo.command(%w(help))
      assert_equal 1, @todo.size
    end

    should "print" do
      @todo.command([])
      assert_equal 1, @todo.size
    end
  end

  context "time" do
    setup do
      @time = Time.now
    end

    should "parse time" do
      @time = @todo.tf("Fri Oct 02 15:04:59 -0700 2009")
    end

    should "have distance in seconds" do
      assert_equal "> 1 sec ago", Time.time_ago(@time, @time - 1)
    end

    should "have distance in minutes" do
      assert_equal "> 5 min ago", Time.time_ago(@time, @time - 5*60)
    end

    should "have distance in 1 hour" do
      assert_equal "~ 1 hr ago", Time.time_ago(@time, @time - 3600)
    end

    should "have distance in hours" do
      assert_equal "~ 2 hrs ago", Time.time_ago(@time, @time - 2*3600)
    end

    should "have distance in 1 day" do
      assert_equal "~ 1 day ago", Time.time_ago(@time, @time - 86400)
    end

    should "have distance in days" do
      assert_equal "~ 7 days ago", Time.time_ago(@time, @time - 7*86400)
    end

    should "have distance in 1 month" do
      assert_equal "~ 1 month ago", Time.time_ago(@time, @time - 2592000)
    end

    should "have distance in months" do
      assert_equal "~ 3 months ago", Time.time_ago(@time, @time - 3*2592000)
    end

    should "have distance in 1 year" do
      assert_equal "~ 1 year ago", Time.time_ago(@time, @time - 31536000)
    end

    should "have distance in years" do
      assert_equal "> 99 years ago", Time.time_ago(@time, @time - 99*31536000)
    end
  end

  context "print" do
    should "have width" do
      assert_equal 100, @todo.width
    end

    should "have a title" do
      assert_equal @todo.width, @todo.title.size
    end

    should "have a horizontal line printer" do
      assert_equal @todo.width, @todo.hl.size
    end
  end

end
