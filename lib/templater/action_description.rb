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
  
  class ArgumentDescription < Description
    
    # Checks if the given argument is valid according to this description
    #
    # === Parameters
    # argument<Object>:: Checks if the given argument is valid.
    # === Returns
    # Boolean:: Validity of the argument
    def valid?(argument)
      
    end
    
  end
end