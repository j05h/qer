%w[rubygems rake rake/clean fileutils hoe newgem rubigen].each { |f| require f }
require File.dirname(__FILE__) + '/lib/qer'

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.spec('qer') do |p|
  p.developer('Josh Kleinpeter', 'josh@kleinpeter.org')
  p.changes              = p.paragraphs_of("History.txt", 0..1).join("\n\n")
  p.post_install_message = 'PostInstall.txt'
  p.rubyforge_name       = p.name
  p.description          = "Qer is an easy command-line todo list."
  p.summary              = "Just type `qer --help` to get started."
  p.extra_dev_deps = [
    ['shoulda','= 2.10.1'],
    ['newgem', ">= #{::Newgem::VERSION}"]
  ]
  
  p.clean_globs |= %w[**/.DS_Store tmp *.log]
  path = (p.rubyforge_name == p.name) ? p.rubyforge_name : "\#{p.rubyforge_name}/\#{p.name}"
  p.remote_rdoc_dir = File.join(path.gsub(/^#{p.rubyforge_name}\/?/,''), 'rdoc')
  p.rsync_args = '-av --delete --ignore-errors'
end

require 'newgem/tasks' # load /tasks/*.rake
Dir['tasks/**/*.rake'].each { |t| load t }

task :default => [:spec]

task :rcov do
  system("rcov -t -x '/.*shoulda.*/|/.*rcov.*/' test/test_qer.rb")
end
