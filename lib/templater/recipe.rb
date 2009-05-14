module Templater
  class Recipe < Struct.new(:name, :conditions)
  
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
  
  end
end