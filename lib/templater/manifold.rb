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
    
    def run_cli(args)
      Templater::CLI.run(self, ['arg', 'blah'])
    end
    
  end
  
end