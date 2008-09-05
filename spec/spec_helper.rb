$TESTING=true
$:.push File.join(File.dirname(__FILE__), '..', 'lib')

def template_path(template)
  File.expand_path(File.join(File.dirname(__FILE__), 'templates', template))
end

def result_path(result)
  File.expand_path(File.join(File.dirname(__FILE__), 'results', result))
end

require 'templater.rb'
require 'rubygems'
require 'spec'
require 'fileutils'

class MatchActionNames
  def initialize(*names)
    @names = names.map{|n| n.to_s}
  end

  def matches?(actual)
    @actual = actual
    @actual.map{|a| a.name.to_s}.sort == @names.sort
  end

  def failure_message
    "expected #{@actual.inspect} to have action names #{@names.inspect}, but they didn't"
  end

  def negative_failure_message
    "expected #{@actual.inspect} not to have action names #{@names.inspect}, but they did"
  end
end

def have_names(*names)
  MatchActionNames.new(*names)
end