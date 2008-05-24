module Templater
  
  class TemplateProxy
    
    def initialize(name, &block)
      @block = block
      @name = name.to_sym
    end
    
    def source(source)
      @source = source
    end
    
    def destination(dest)
      @destination = dest
    end
    
    def to_template(generator)
      @generator = generator
      instance_eval(&@block)
      @generator = nil
      Templater::Template.new(@name, generator, @source, @destination)
    end
    
    def method_missing(method, *args, &block)
      if @generator
        @generator.send(method, *args, &block)
      else
        super
      end
    end
    
  end
  
end