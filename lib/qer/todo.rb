module Qer
  class ToDo
    class << self
      attr_accessor :quiet
    end

    attr_accessor :queue
    
    def initialize(filename = File.expand_path("~/.binqueue"))
      @filename  = filename
      self.queue = Marshal.load(file) rescue []
    end

    def file(mode = "r")
      File.new(@filename, mode)
    end
    
    def size
      self.queue.size
    end
    
    def returning(thing)
      yield
      thing
    end
    
    def add(item)
      self.queue << [Time.now.to_s, item]
      write
      print "Adding: "+item
    end
    
    def remove(index)
      returning(item = self.queue.delete_at(index)) do
        write
        print "Removed #{item.last}"
      end
    end

    def clear
      self.queue = []
      write
      print "ToDo list cleared"
    end

    def pop
      remove(0)
    end

    def push(item)
      self.queue.unshift([Time.now.to_s, item])
      write
      print
    end

    def bump(index, new_index = 0)
      item = queue.delete_at(index.to_i)
      queue.insert(new_index.to_i, item)
      write
      print "Bumped #{item.last} to position #{new_index}"
    end

    def write
      Marshal.dump(self.queue, file("w+"))
    end

    def width
      80
    end

    def title
      "> Stuff on the Hopper < ".center(width, '-')
    end

    def hl
      "".center(width, '-')
    end
        
    def tf(t)
      Time.time_ago(Time.parse(t))
    end
    
    def process_line(index, item)
      time, task = item
      left       = "(#{index}) #{task}"
      right      = tf(time).rjust(width - left.length)
      right.insert(0, left)
    end

    def print(string = nil)
      out = []
      out << string if(string)
      out << title
      out << hl
      if(self.queue.size > 0)
        self.queue.each_index do |index|
          out << process_line(index, self.queue[index])
        end
      else
        out << "Nothing to do!"
      end
      out << hl
      puts out.join("\n") unless self.class.quiet
    end
    
    def command(args)
      case(args.shift)
      when /^a(dd)?/   : self.add(args.join(" "))     # qer add Some task 1
      when /^r(emove)?/: self.remove(args.shift.to_i) # qer remove 0
      when /^pu(sh)?/  : self.push(args.join(" "))    # qer push Some task 2
      when /^po(p)?/   : self.pop                     # qer pop
      when /^b(ump)?/  : bump(*args.first(2))         # qer bump
      when /^clear/    : self.clear                   # qer clear 
      when /.*help/    : self.help                    # qer help
      else self.print                                 # qer
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
  help - Prints this message
    `qer help`
#{hl}    
      EOF
      puts string unless self.class.quiet
    end
  end
end
