require 'rubygems'
gem 'hoe', '>= 2.1.0'
require 'hoe'
require 'fileutils'
require './lib/templater'

Hoe.plugin :newgem

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.spec 'templater' do
  self.developer 'Jonas Nicklas', 'jonas.nicklas@gmail.com'
  self.rubyforge_name = self.name
  self.extra_deps << ['highline', ">= 1.4.0"]
  self.extra_deps << ['diff-lcs', ">= 1.1.2"]
  self.extra_deps << ['activesupport', "~> 3.0"]
  self.extra_dev_deps << ['rspec', '>= 2.0']
end

require 'newgem/tasks'
Dir['tasks/**/*.rake'].each { |t| load t }
