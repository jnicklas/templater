path = File.dirname(__FILE__) + '/templater/'

require path + 'parser'
require path + 'template'
require path + 'generator'
require path + 'template_proxy'

require 'erb'

module Templater
  
  class TemplaterError < StandardError; end
  class GeneratorError < TemplaterError; end
  class ArgumentError < GeneratorError; end
  class TooManyArgumentsError < ArgumentError; end
  class TooFewArgumentsError < ArgumentError; end
  class JustTheRightAmountOfArgumentsError < ArgumentError; end
  class MalformattedArgumentError < ArgumentError; end
  
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