module Templater
  
  module Manifold
    
    attr_accessor :generators
    
    # Add a generator to this manifold
    # 
    # === Parameters
    # name<Symbol>:: The name given to this generator in the manifold
    # generator<Templater::Generator>:: The generator class
    def add(name, generator)
      @generators ||={}
      @generators[name.to_sym] = generator
      (class << self; self; end).module_eval <<-MODULE
        def #{name}
          generator(:#{name})
        end
      MODULE
    end
    
    # Remove the generator with the given name from the manifold
    #
    # === Parameters
    # name<Symbol>:: The name of the generator to be removed.
    def remove(name)
      @generators.delete(name.to_sym)
      (class << self; self; end).module_eval <<-MODULE
        undef #{name}
      MODULE
    end
    
    # Finds the class of a generator, given its name in the manifold.
    #
    # === Parameters
    # name<Symbol>:: The name of the generator to find
    #
    # === Returns
    # Templater::Generator:: The found generator class
    def generator(name)
      @generators ||= {}
      @generators[name.to_sym]
    end
    
    # A Shortcut method for invoking the command line interface provided with Templater.
    #
    # === Parameters
    # destination_root<String>:: Where the generated files should be put, this would usually be Dir.pwd
    # name<String>:: The name of the executable running this generator (such as 'merb-gen')
    # version<String>:: The version number of the executable.
    # args<Array[String]>:: An array of arguments to pass into the generator. This would usually be ARGV
    def run_cli(destination_root, name, version, args)
      Templater::CLI::Manifold.run(destination_root, self, name, version, args)
    end
    
    # If the argument is omitted, simply returns the description for this manifold, otherwise
    # sets the description to the passed string.
    #
    # === Parameters
    # text<String>:: A description
    #
    # === Returns
    # String:: The description for this manifold
    def desc(text = nil)
      @text = text if text
      return @text.realign_indentation
    end
    
  end
  
end