path = File.dirname(__FILE__) + '/templater/'

require 'rubygems'
require 'highline'
require "highline/import"
require 'diff/lcs'


require path + 'capture_helpers'
require path + 'template'
require path + 'file'
require path + 'empty_directory'
require path + 'generator'
require path + 'proxy'
require path + 'manifold'
require path + 'cli/parser'
require path + 'cli/manifold'
require path + 'cli/generator'
require path + 'core_ext/string'
require path + 'core_ext/kernel'

require 'erb'

module Templater
  
  class TemplaterError < StandardError #:nodoc:
  end
  class GeneratorError < TemplaterError #:nodoc:
  end
  class SourceNotSpecifiedError < TemplaterError #:nodoc:
  end
  class ArgumentError < GeneratorError #:nodoc:
  end
  class TooManyArgumentsError < ArgumentError #:nodoc:
  end
  class TooFewArgumentsError < ArgumentError #:nodoc:
  end
  class JustTheRightAmountOfArgumentsError < ArgumentError #:nodoc:
  end
  class MalformattedArgumentError < ArgumentError #:nodoc:
  end
  
  VERSION = '0.1.3'
  
end
