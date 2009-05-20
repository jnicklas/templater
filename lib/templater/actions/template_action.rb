module Templater
  module Actions
    class TemplateAction < FileAction

      # Renders the template using ERB and returns the result as a String.
      #
      # === Returns
      # String:: The rendered template.
      def render
        context = @generator.instance_eval 'binding'
        ERB.new(::File.read(source), nil, '-').result(context)
      end

      def status
        return :identical if ::File.exists?(destination) and ::File.read(destination) == render
        return :conflict if ::File.exists?(destination)
        return :ok
      end

      # Renders the template and copies it to the destination.
      def invoke!
        ::FileUtils.mkdir_p(::File.dirname(destination))
        ::File.open(destination, 'w') {|f| f.write render }
      end

      # removes the destination file
      def revoke!
        ::FileUtils.rm(destination, :force => true)
      end

    end

    def template(source, destination)
      action(Templater::Actions::TemplateAction.new(@generator, source, destination))
    end

  end
end
