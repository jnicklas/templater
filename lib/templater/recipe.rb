module Templater
  # TODO: this class is fugly, refactor!
  class Recipe < Struct.new(:name, :conditions, :block)

    def invoke!(generator)
      @actions = []
      @generator = generator
      instance_eval(&block)
      @generator = nil
    end

    attr_accessor :actions

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

    def use?(generator)
      case conditions
      when Hash
        use = true
        use = false if conditions[:if] and not generator.send(conditions[:if])
        use = false if conditions[:unless] and generator.send(conditions[:unless])
        use
      else
        use = conditions
      end
    end

  private
  
    def method_missing(*args)
      @generator.send(*args)
    end

  end
end