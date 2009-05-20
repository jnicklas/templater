module Templater
  module Actions

    class DirectoryAction < FileAction

      def invoke!
        ::FileUtils.mkdir_p(::File.dirname(destination))
        ::FileUtils.cp_r(source, destination)
      end

      def revoke!
        ::FileUtils.rm_r(destination, :force => true)
      end
    end

    def template(source, destination)
      action(Templater::Actions::DirectoryAction.new(@generator, source, destination))
    end

  end
end
