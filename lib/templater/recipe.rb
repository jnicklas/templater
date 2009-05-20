module Templater
  # TODO: this class is fugly, refactor!
  class Recipe

    include Templater::Actions

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