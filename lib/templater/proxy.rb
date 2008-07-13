module Templater
  
  class Proxy #:nodoc:
    
    def initialize(generator, name, source, destination, &block)
      @generator, @block, @source, @destination = generator, block, source, destination
      @name = name.to_sym
    end
    
    def source(*source)
      @source = ::File.join(*source)
    end
    
    def destination(*dest)
      @destination = ::File.join(*dest)
    end
    
    def to_template
      instance_eval(&@block) if @block
      Templater::Template.new(@generator, @name, get_source, get_destination)
    end
    
    def to_file
      instance_eval(&@block) if @block
      Templater::File.new(@name, get_source, get_destination)
    end
    
    def method_missing(method, *args, &block)
      if @generator
        @generator.send(method, *args, &block)
      else
        super
      end
    end
    
    protected
    
    def get_source
      ::File.expand_path(@source.to_s, @generator.source_root)
    end
    
    def get_destination
      ::File.expand_path(convert_encoded_instructions(@destination.to_s), @generator.destination_root)
    end
    
    def convert_encoded_instructions(filename)
      filename.gsub(/%.*?%/) do |string|
        instruction = string.match(/%(.*?)%/)[1]
        @generator.respond_to?(instruction) ? @generator.send(instruction) : string
      end
    end
    
  end
  
end