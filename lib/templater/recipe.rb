module Templater
  class Recipe < Struct.new(:name, :options)
  
    def use?(generator)
      use = true
      use = false if options[:if] and not generator.send(options[:if])
      use = false if options[:unless] and generator.send(options[:unless])
      use
    end
  
  end
end