module Templater
  module Actions
    class Directory < FileAction

      def invoke!
        ::FileUtils.mkdir_p(::File.dirname(destination))
        ::FileUtils.cp_r(source, destination)
      end

      def revoke!
        ::FileUtils.rm_r(destination, :force => true)
      end
    end
  end
end
