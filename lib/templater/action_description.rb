module Templater
  
  class Description
    attr_accessor :name, :options, :block
    
    def initialize(name, options={}, &block)
      @name = name
      @options = options
      @block = block
    end    
  end
  
  class ActionDescription < Description
    
    def compile(generator)
      @block.call(generator)
    end
    
  end
end