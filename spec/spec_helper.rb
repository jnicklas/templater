$TESTING=true
$:.push File.join(File.dirname(__FILE__), '..', 'lib')

def template_path(template)
  File.join(File.dirname(__FILE__), 'templates', template)
end

def result_path(result)
  File.join(File.dirname(__FILE__), 'results', result)
end

require 'templater.rb'
require 'rubygems'
require 'spec'
require 'fileutils'