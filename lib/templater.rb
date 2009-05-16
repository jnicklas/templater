path = File.dirname(__FILE__) + '/templater/'

require 'rubygems'
require 'extlib'
require "fileutils"
require 'highline'
require "highline/import"
require 'diff/lcs'

require path + 'discovery'
require path + 'capture_helpers'
require path + 'actions/action'
require path + 'actions/file_action'
require path + 'actions/template_action'
require path + 'actions/directory_action'
require path + 'actions/simple_action'
require path + 'description'
require path + 'recipe'
require path + 'generator'
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
  
  VERSION = '0.5.0'
  
end
