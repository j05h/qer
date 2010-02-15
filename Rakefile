%w[rubygems rake rake/clean fileutils hoe].each { |f| require f }
require File.dirname(__FILE__) + '/lib/qer'

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.spec('qer') do
  developer('Josh Kleinpeter', 'josh@kleinpeter.org')
  developer('Coby Randquist', 'randquistcp@gmail.com')
  developer('Jacob Dunphy', 'jacob.dunphy@gmail.com')
  self.changes              = paragraphs_of("History.txt", 0..1).join("\n\n")
  self.rubyforge_name       = name
  self.description          = "Qer is an easy command-line todo list."
  self.summary              = "Just type `qer --help` to get started."
  self.extra_dev_deps = [
    ['shoulda','> 2.10.1'],
  ]

  self.clean_globs |= %w[**/.DS_Store tmp *.log]
  self.rsync_args = '-av --delete --ignore-errors'
end

require 'newgem/tasks' # load /tasks/*.rake
Dir['tasks/**/*.rake'].each { |t| load t }

task :default => [:spec]

task :rcov do
  system("rcov -t -x '/.*shoulda.*/|/.*rcov.*/' test/test_qer.rb")
end
