module Templater
  
  class TemplateProxy
    
    def initialize(&block)
      self.block = block
    end
    
    attr_accessor :block, :generator, :source, :destination, :use
    
    
    
    def source
      
    end
    
    def to_template(generator)
      self.generator = generator
      Templater::Template.new(source, destination)
    end
    
    def method_missing(:method, *args, &block)
      if self.generator
        self.generator.send(:method, *args, &block)
      else
        super
      end
    end
    
  end
  
end