module Templater
  class Template
  
    attr_accessor :context, :name, :source, :destination, :options
  
    def initialize(context, name, source, destination, render = true)
      @context = context
      @name = name
      @source = source
      @destination = destination
      @options = { :render => render }
    end
    
    def relative_destination
      @destination.sub(Dir.pwd + '/', '')
    end
  
    # Renders the template, and returns the result as a string
    def render
      ERB.new(File.read(source), nil, '-').result(context.send(:binding))
    end

    # returns true if the destination file exists.
    def exists?
      File.exists?(destination)
    end
  
    # returns true if the content of the file at the destination is identical to the rendered result.
    def identical?
      File.read(destination) == render if File.exists?(destination)
    end
  
    # Renders the template and copies it to the destination
    def invoke!
      FileUtils.mkdir_p(File.dirname(destination))
      if options[:render]
        File.open(destination, 'w') {|f| f.write render }
      else
        FileUtils.copy_file(source, destination)
      end
    end
  
  end
end