module Templater
  
  class CLI
    
    def self.run(manifold, arguments)
      generator = manifold.generator(ARGV.first)
      
      Templater::Parser.parse(arguments) do |opts, options|
        generator.options.each do |name, settings|
          opts.on("--#{name}", settings[:desc]) do |s|
            options[name] = settings
          end
        end
      end
    end
    
    def self.invoke(generator, options, arguments)
      
    end
    
  end
  
end