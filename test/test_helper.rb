require 'stringio'
require 'test/unit'
require 'shoulda'
require 'qer'

Qer::ToDo.quiet = true

class Test::Unit::TestCase

  def assert_output matcher
    assert_match matcher, read_stdout
  end

  def read_stdout
    @output.rewind
    @output.read
  end

  def with_config(config)
    tmp_config = 'test/tmp-config'

    File.open(tmp_config, 'w') do |f|
      f << YAML.dump(config)
    end

    yield Qer::ToDo.new(tmp_config)

  ensure
    File.delete(tmp_config) if File.exist?(tmp_config)
  end
end
