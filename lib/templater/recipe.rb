module Templater
  # TODO: this class is fugly, refactor!
  class Recipe

    def initialize(generator, name, options, &block)
      @generator = generator
      @name = name
      @options = options
      @block = block
    end

    def invoke!
      @actions = []
      instance_eval(&block)
    end

    attr_accessor :actions, :name, :options, :block

    def actions
      @actions ||= []
    end

    def action(action)
      actions.push(action)
    end

    def simple_action(description, &block)
      action(Templater::Actions::SimpleAction.new(@generator, description, &block))
    end

    def template(source, destination)
      action(Templater::Actions::TemplateAction.new(@generator, source, destination))
    end

    def generate(generator, *args)
      self.actions += generator.new(destination_root, *args).actions
    end

    def use?
      case options
      when Hash
        use = true
        use = false if options[:if] and not @generator.send(options[:if])
        use = false if options[:unless] and @generator.send(options[:unless])
        use
      else
        use = options
      end
    end

  private
  
    def method_missing(*args)
      @generator.send(*args)
    end

  end
end