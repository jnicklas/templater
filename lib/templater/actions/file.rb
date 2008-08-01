module Templater
  module Actions
    class File
  
      attr_accessor :name, :source, :destination
  
      # Builds a new file, given the name of the file and its source and destination.
      #
      # === Parameters
      # name<Symbol>:: The name of this template
      # source<String>:: Full path to the source of this template
      # destination<String>:: Full path to the destination of this template
      def initialize(name, source, destination)
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
        ::FileUtils.mkdir_p(::File.dirname(destination))
        ::FileUtils.copy_file(source, destination)
      end
    
      # removes the destination file
      def revoke!
        ::FileUtils.rm(destination)
      end
  
    end
  end
end
