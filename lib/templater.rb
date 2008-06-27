path = File.dirname(__FILE__) + '/templater/'

require 'rubygems'
require 'highline'
require "highline/import"
require 'diff/lcs'
require 'facets'


require path + 'capture_helpers'
require path + 'template'
require path + 'generator'
require path + 'template_proxy'
require path + 'manifold'
require path + 'cli/parser'
require path + 'cli/manifold'
require path + 'cli/generator'
require path + 'core_ext/string'

require 'erb'

module Templater
  
  class TemplaterError < StandardError; end
  class GeneratorError < TemplaterError; end
  class SourceNotSpecifiedError < TemplaterError; end
  class ArgumentError < GeneratorError; end
  class TooManyArgumentsError < ArgumentError; end
  class TooFewArgumentsError < ArgumentError; end
  class JustTheRightAmountOfArgumentsError < ArgumentError; end
  class MalformattedArgumentError < ArgumentError; end
  
  VERSION = '0.1'
  
end