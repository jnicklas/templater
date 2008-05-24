path = File.dirname(__FILE__) + '/templater/'

require path + 'parser'
require path + 'template'
require path + 'generator'
require 'erb'

module Templater
  
  class TemplaterError < StandardError; end
  class GeneratorError < TemplaterError; end
  class TooManyArgumentsError < GeneratorError; end
  class MalformattedArgumentError < GeneratorError; end
  
  def self.generators
    @generators ||= {}
  end
  
  def self.register_generator(name, generator)
    generators[name] = generator
  end
  
  def invoke!(name)
    self.generators[name].invoke!
  end
  
end