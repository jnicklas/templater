module Templater
  module Actions
    class File
  
      attr_accessor :name, :source, :destination, :options
  
      # Builds a new file, given the name of the file and its source and destination.
      #
      # === Parameters
      # name<Symbol>:: The name of this template
      # source<String>:: Full path to the source of this template
      # destination<String>:: Full path to the destination of this template
      def initialize(generator, name, source, destination, options={})
        @generator = generator
        @name = name
        @source = source
        @destination = destination
        @options = options
      end
    
      # Returns the destination path relative to Dir.pwd. This is useful for prettier output in interfaces
      # where the destination root is Dir.pwd.
      #
      # === Returns
      # String:: The destination relative to Dir.pwd
      def relative_destination
        @destination.relative_path_from(@generator.destination_root)
      end

      # Returns the contents of the source file as a String
      #
      # === Returns
      # String:: The source file.
      def render
        ::File.read(source)
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
        exists? && ::FileUtils.identical?(source, destination)
      end
  
      # Renders the template and copies it to the destination.
      def invoke!
        @generator.send(@options[:before]) if @options[:before]
        ::FileUtils.mkdir_p(::File.dirname(destination))
        ::FileUtils.copy_file(source, destination)
        @generator.send(@options[:after]) if @options[:after]
      end
    
      # removes the destination file
      def revoke!
        ::FileUtils.rm(destination, :force => true)
      end
  
    end
  end
end
