module Templater
  module Actions
    
    class SimpleAction < Action

      def initialize(generator, description, &block)
        @generator = generator
        @description = description
        @block = block
      end

      def description
        @description
      end

      def invoke!
        @generator.instance_eval(&@block)
      end

    end

    def simple_action(description, &block)
      action(Templater::Actions::SimpleAction.new(@generator, description, &block))
    end

  end
end
