module Templater
  module Actions
    class EmptyDirectory

      attr_accessor :generator, :name, :destination, :options
    
      def initialize(generator, name, destination, options={})
        self.generator = generator
        self.name = name
        self.destination = destination
        self.options = options
      end

      def destination=(destination)
        unless destination.blank?
          @destination = ::File.expand_path(convert_encoded_instructions(destination), generator.destination_root)
        end
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
  
      # For empty directory this is in fact alias for exists? method.
      # 
      # === Returns
      # Boolean:: true if it is identical, false otherwise.
      def identical?
        exists?
      end
  
      # Renders the template and copies it to the destination.
      def invoke!
        @generator.send(@options[:before], self) if @options[:before]
        ::FileUtils.mkdir_p(destination)
        @generator.send(@options[:after], self) if @options[:after]
      end
    
      # removes the destination file
      def revoke!
        ::FileUtils.rm_rf(::File.expand_path(destination))
      end
      
      protected
      
      def convert_encoded_instructions(filename)
        filename.gsub(/%.*?%/) do |string|
          instruction = string.match(/%(.*?)%/)[1]
          @generator.respond_to?(instruction) ? @generator.send(instruction) : string
        end
      end
    end # EmptyDirectory
  end # Actions
end # Templater
