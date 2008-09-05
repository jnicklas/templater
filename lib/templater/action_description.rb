module Templater
  class ActionDescription
    
    attr_accessor :name, :options
    
    def initialize(name, options={}, &block)
      @name = name
      @options = options
      @block = block
    end
    
    def compile(generator)
      @block.call(generator)
    end
    
  end
end