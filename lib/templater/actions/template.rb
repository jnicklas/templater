module Templater
  module Actions
    class Template
  
      attr_accessor :context, :name, :source, :destination, :options
  
      # Builds a new template, given the context (e.g. binding) in which the template will be rendered
      # (usually a generator), the name of the template and its source and destination.
      #
      # === Parameters
      # context<Object>:: Context for rendering
      # name<Symbol>:: The name of this template
      # source<String>:: Full path to the source of this template
      # destination<String>:: Full path to the destination of this template
      # render<Boolean>:: If set to false, will do a copy instead of rendering.
      def initialize(context, name, source, destination)
        @context = context
        @name = name
        @source = source
        @destination = destination
      end
    
      # Returns the destination path relative to Dir.pwd. This is useful for prettier output in interfaces
      # where the destination root is Dir.pwd.
      #
      # === Returns
      # String:: The destination relative to Dir.pwd
      def relative_destination
        @destination.sub(::Dir.pwd + ::File::SEPARATOR, '')
      end
  
      # Renders the template using ERB and returns the result as a String.
      #
      # === Returns
      # String:: The rendered template.
      def render
        ERB.new(::File.read(source), nil, '-').result(context.send(:binding))
      end

      # Checks if the destination file already exists.
      #
      # === Returns
      # Boolean:: true if the file exists, false otherwise.
      def exists?
        ::File.exists?(destination)
      end
  
      # Checks if the content of the file at the destination is identical to the rendered result.
      # 
      # === Returns
      # Boolean:: true if it is identical, false otherwise.
      def identical?
        ::File.read(destination) == render if ::File.exists?(destination)
      end
  
      # Renders the template and copies it to the destination.
      def invoke!
        ::FileUtils.mkdir_p(::File.dirname(destination))
        ::File.open(destination, 'w') {|f| f.write render }
      end
    
      # removes the destination file
      def revoke!
        ::FileUtils.rm(destination)
      end
      
    end
  end
end
