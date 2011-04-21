require 'test_helper.rb'

class TestQer < Test::Unit::TestCase

  def setup
    queue = File.join(File.dirname(__FILE__), 'testqueue.tmp')
    File.delete(queue) if File.exists?(queue)

    @config = File.join(File.dirname(__FILE__), 'config')
    @todo = Qer::ToDo.new(@config)
  end

  context "push" do
    setup do
      @todo.push("Some Task")
    end

    should "have one item" do
      assert_equal 1, @todo.queue.size
    end

    should "have two items" do
      @todo.push("Some Other Task")
      assert_equal 2, @todo.queue.size
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
      assert_equal 1, @todo.queue.size
    end
  end

  context "add" do
    setup do
      @todo.add("Some Task")
    end

    should "have one item" do
      assert_equal 1, @todo.queue.size
    end

    should "have two items" do
      @todo.add("Some Other Task")
      assert_equal 2, @todo.queue.size
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
      assert_equal 1, @todo.queue.size
    end

    should "not error out when an invalid index is removed" do
      assert_nothing_raised {
        @todo.remove(12)
      }
    end
  end

  context "clear all" do
    setup do
      @todo.add("Some Task")
      @todo.add("Some Other Task")
      @todo.clear
    end

    should "have no items" do
      assert_equal 0, @todo.queue.size
    end
  end

  context "clear individual item" do
    setup do
      @todo.add("Some Task")
      @todo.add("Some Other Task")
      @item = @todo.clear(0)
    end

    should "have the right item left" do
      assert_equal "Some Task", @item[1]
    end

    should "have one item" do
      assert_equal 1, @todo.queue.size
    end
  end

  context "bump" do
    setup do
      @todo.add("first")
      @todo.add("second")
      @todo.add("third")
    end

    should "be able to bump to the top" do
      @todo.bump(2)
      assert_equal "third", @todo.queue.first.last
    end

    should "be able to bump to a specific location" do
      @todo.bump(2,1)
      assert_equal "third", @todo.queue[1].last
    end

    should "not leave nil rows in if we bump too far back" do
      @todo.bump(0,100)
      assert !@todo.queue.include?(nil)
      assert_equal "first", @todo.queue.last[1] 
    end
  end

  context "read" do
    setup do
      config = File.join(File.dirname(__FILE__), 'static-config')
      @todo = Qer::ToDo.new(config)
    end

    should "have 5 items" do
      assert_equal 5, @todo.queue.size
    end
  end

  context "write" do
    setup do
      @todo.add("Some Task")
      @todo.add("Some Other Task")
    end

    should "have 2 items" do
      assert_equal 2, @todo.queue.size
    end
  end

  context "command" do
    setup do
      @todo.add("Some Task")
      Qer::ToDo.quiet = false
      @orig_stdout = $stdout.dup
      @output = StringIO.new
      $stdout = @output
    end

    teardown do
      Qer::ToDo.quiet = true
      $stdout = @orig_stdout
    end

    should "add" do
      @todo.command(%w(add some stuff))
      assert_equal 2, @todo.queue.size
      assert_output(/Adding: some stuff/)
    end

    should "add with shorthand cmd" do
      @todo.command(%w(a some stuff))
      assert_equal 2, @todo.queue.size
      assert_output(/Adding: some stuff/)
    end

    should "not add" do
      @todo.command(%w(asdf))
      assert_equal 1, @todo.queue.size
      assert_output(/did not recognize/i)
    end

    should "remove" do
      assert_equal "Some Task", @todo.command(%w(remove 0)).last
      assert_equal 0, @todo.queue.size
      assert_output "Removed: Some Task"
    end

    should "not remove bad index" do
      @todo.command(%w(remove 14))
      assert_output "Provided index does not exist."
    end

    should "not remove anything with nil index" do
      @todo.command(%w(remove))
      assert_output /Remove must have an index:/
      assert_equal 1, @todo.queue.size
    end

    should "push" do
      @todo.command(%w(push some stuff))
      assert_equal 2, @todo.queue.size
      assert_output "Pushed to the top: some stuff"
    end

    should "pop" do
      assert_equal "Some Task", @todo.command(%w(pop)).last
      assert_equal 0, @todo.queue.size
      assert_output "Removed: Some Task"
    end

    should "clear" do
      @todo.command(%w(clear))
      assert_equal 0, @todo.queue.size
      assert_output(/list cleared/)
    end

    should "help" do
      @todo.command(%w(help))
      assert_equal 1, @todo.queue.size
      assert_output(/Help for Qer/)
    end

    should "print" do
      @todo.command([])
      assert_equal 1, @todo.queue.size
      assert_output "Stuff on the Hopper"
    end

    should "bump" do
      @todo.add("second")
      @todo.command(%w(bump 1))
      assert_equal "second", @todo.queue.first.last

      assert_output(/Bumped second to position 0/)

      @todo.add('third')
      @todo.command(%w(bump 2 1))
      assert_equal "third", @todo.queue[1].last

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
      assert_equal 80, @todo.width
    end

    should "have a title" do
      assert_equal @todo.width, @todo.title.size
    end

    should "have a horizontal line printer" do
      assert_equal @todo.width, @todo.hl.size
    end
  end

  context "config" do
    should "set #filename" do
      with_config('queue_file' => 'foo') do |todo|
        assert_equal File.expand_path('foo'), todo.filename
      end
    end

    should "set #width" do
      with_config('page_width' => 120) do |todo|
        assert_equal 120, todo.width
      end
    end

    should "set #history_limit" do
      with_config('history_limit' => 40) do |todo|
        assert_equal 40, todo.history_limit
      end
    end
  end
end
