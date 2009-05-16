module Templater
  module Actions
    class FileAction < Action

      # Builds a new template.
      #
      # === Parameters
      # generator<Object>:: Context for rendering
      # source<String>:: Full path to the source of this template
      # destination<String>:: Full path to the destination of this template
      def initialize(generator, source, destination)
        @generator = generator
        @source = source
        @destination = destination
      end

      def description
        relative_destination
      end

      def source
        ::File.expand_path(@source, @generator.source_root)
      end
      
      def destination
        ::File.expand_path(convert_encoded_instructions(@destination), @generator.destination_root)
      end

      # Returns the destination path relative to Dir.pwd. This is useful for prettier output in interfaces
      # where the destination root is Dir.pwd.
      #
      # === Returns
      # String:: The destination relative to Dir.pwd
      def relative_destination
        destination.relative_path_from(@generator.destination_root)
      end

    private

      def convert_encoded_instructions(filename)
        filename.gsub(/%.*?%/) do |string|
          instruction = string.match(/%(.*?)%/)[1]
          @generator.respond_to?(instruction) ? @generator.send(instruction) : string
        end
      end
      
    end
  end
end
