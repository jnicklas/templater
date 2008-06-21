module Templater
  
  class TemplateProxy
    
    def initialize(name, source, destination, render, &block)
      @block = block
      @name = name.to_sym
      @source = source
      @destination = destination
      @render = render
    end
    
    def source(source)
      @source = source
    end
    
    def destination(dest)
      @destination = dest
    end
    
    def to_template(generator)
      @generator = generator
      instance_eval(&@block) if @block
      @generator = nil
      Templater::Template.new(generator, @name, File.join(generator.source_root, @source.to_s), File.join(generator.destination_root, @destination.to_s), @render)
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