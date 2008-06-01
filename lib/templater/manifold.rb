module Templater
  
  module Manifold
    
    attr_accessor :generators
    
    def add(name, generator)
      @generators ||={}
      @generators[name.to_sym] = generator
      (class << self; self; end).module_eval <<-MODULE
        def #{name}
          @generators[:#{name}]
        end
      MODULE
    end
    
    def remove(name)
      @generators.delete(name.to_sym)
      (class << self; self; end).module_eval <<-MODULE
        undef #{name}
      MODULE
    end
    
    def generator(name)
      @generators ||= {}
      @generators[name.to_sym]
    end
    
    def run_cli(destination_root, name, version, args)
      Templater::CLI.run(destination_root, self, name, version, args)
    end
    
    def desc(text = nil)
      @text = text if text
      return @text.realign_indentation
    end
    
  end
  
end