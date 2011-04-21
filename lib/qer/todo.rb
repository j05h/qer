module Qer
  class ToDo

    CONFIG_PATH = File.expand_path("~/.qer")

    class << self
      attr_accessor :quiet
    end

    attr_accessor :queue
    attr_accessor :history

    def initialize(config_file = CONFIG_PATH)
      load_config(config_file)

      file {|f| self.queue = Marshal.load(f) } rescue self.queue= []
      history_file {|f| self.history = Marshal.load(f) } rescue self.history= []
    end

    def add(item)
      self.queue << [Time.now.to_s, item]
      write
      print "Adding: "+item
    end

    def remove(index)
      if item = self.queue.delete_at(index)
        self.history << [Time.now.to_s, item[0], item[1]]
        write_history
        write
        print "Removed: #{item.last}"
        item
      else
        print "Provided index does not exist."
      end
    end

    def clear(index = nil)
      unless index.nil?
        item = self.queue.delete_at(index.to_i)
        write
        print "Removed #{item.last}"
        item
      else
        self.queue = []
        write
        print "ToDo list cleared"
      end
    end

    def pop
      remove(0)
    end

    def push(item)
      self.queue.unshift([Time.now.to_s, item])
      write
      print "Pushed to the top: #{item}"
    end

    def bump(index, new_index = 0)
      item = queue.delete_at(index.to_i)
      self.queue.insert(new_index.to_i, item)
      self.queue.delete_if {|i| i.nil? }
      write
      print "Bumped #{item.last} to position #{new_index}"
    end

    def print(string = nil)
      dump self.queue, string
    end

    def print_history(string = nil)
      dump self.history.last(history_limit), string, history_title
    end

    def write
      file("w+") {|f| Marshal.dump(self.queue, f) }
    end

    def write_history
      history_file("w+") {|f| Marshal.dump(self.history, f) }
    end

    def history_limit
      @config["history_limit"] || 30
    end

    def file(mode = "r", &block)
      File.open(filename, mode) { |f| yield f }
    end

    def history_file(mode = "r", &block)
      File.open(history_filename, mode) { |f| yield f }
    end

    def width
      @config["page_width"] || 80
    end

    def load_config(path)
      @config = {}
      return unless File.exist?(path)
      @config = YAML.load_file(path)
    rescue StandardError => e
      puts "Error during config file loading."
      puts "Error: #{e.name} - #{e.message}"
    end

    def filename
      @filename ||= File.expand_path(@config["queue_file"] || "~/.qer-queue")
    end

    def history_filename
      @history_filename ||= "#{filename}-history"
    end

    def title
      "> Stuff on the Hopper < ".center(width, '-')
    end

    def history_title
      "> Stuff Completed < ".center(width, '-')
    end

    def hl
      "".center(width, '-')
    end

    def tf(t)
      Time.time_ago(Time.parse(t))
    end

    def print_line(index, item)
      return unless item
      item.size == 2 ? print_queue_line(index,item) : print_history_line(item)
    end

    def print_queue_line(index, item)
      time, task = item
      left       = "(#{index}) #{task}"
      right      = tf(time).rjust(width - left.length)
      right.insert(0, left)
    end

    def print_history_line(item)
      end_time, time, task = item
      right     = "#{tf(time)} | #{tf(end_time)}".rjust(width-task.length)
      right.insert(0, task)
    end

    def dump(queue, string, label = title)
      out = []
      out << string if(string)
      out << label
      out << hl
      unless queue.empty?
        queue.each_with_index do |item, index|
          out << print_line(index, item)
        end
      else
        out << "Nothing in this queue!"
      end
      out << hl
      puts out.join("\n") unless self.class.quiet
    end

    def command(args)
      cmd = args.shift
      case(cmd)
      when "add", "a"
        self.add(args.join(" "))     # qer add Some task 1
      when "remove", "r"
        self.remove(args.shift.to_i) # qer remove 0
      when "push", "pu"
        self.push(args.join(" "))    # qer push Some task 2
      when "pop", "po"
        self.pop                     # qer pop
      when "bump", "b"
        self.bump(*args.first(2))    # qer bump
      when "clear"
        self.clear(args.shift)       # qer clear
      when /.*help/
        self.help                    # qer help
      when "history", "h"
        self.print_history           # qer history
      when "", nil
        self.print                # qer
      else
        self.no_match cmd
      end
    end

    def help
      string = <<-EOF
#{hl}
Help for Qer, the friendly easy todo list queueing system.
#{hl}
Commands:
  print - Prints out the task list
    `qer`
  a(dd) - Adds a task to the end of the list
    `qer add Stuff to do`
  r(emove) - Remove the given task number from the list
    `qer remove 2`
  pu(sh) - Push a task onto the top of the list
    `qer push Another boring thing`
  po(p) - Pops the top item off the list
    `qer pop`
  b(ump) - Bumps the given index to the top of the list,
           or to the specified index
    `qer bump 3`   -> bumps index 3 up to the top
    `qer bump 5 2` -> bumps index five up to 2
  clear - Clears the entire list
    `qer clear`
  clear - Clears the given index without writing to history file
    `qer clear 3`
  h(istory) - displays list of completed tasks
    `qer history`
  help - Prints this message
    `qer help`
#{hl}
      EOF
      puts string unless self.class.quiet
    end

    def no_match cmd
      puts "Did not recognize command: #{cmd}"
    end
  end
end
