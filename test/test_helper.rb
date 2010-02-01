require 'stringio'
require 'test/unit'
require 'shoulda'
require File.dirname(__FILE__) + '/../lib/qer'

Qer::ToDo.quiet = true

class Test::Unit::TestCase

  def assert_output matcher
    assert_match matcher, read_stdout
  end
  
  def read_stdout
    @output.rewind
    @output.read
  end

end
