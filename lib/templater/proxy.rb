module Templater
  
  class Proxy #:nodoc:
    
    def initialize(generator, action={})
      @generator = generator
      @block = action[:block]
      @source, @destination = action[:source], action[:destination]
      @name = action[:name]
    end
    
    def source(*source)
      @source = ::File.join(*source)
    end
    
    def destination(*dest)
      @destination = ::File.join(*dest)
    end
    
    def to_template
      instance_eval(&@block) if @block
      Templater::Actions::Template.new(@generator, @name, get_source, get_destination)
    end
    
    def to_file
      instance_eval(&@block) if @block
      Templater::Actions::File.new(@name, get_source, get_destination)
    end

    def to_empty_directory
      instance_eval(&@block) if @block
      Templater::Actions::EmptyDirectory.new(@name, get_destination)
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
