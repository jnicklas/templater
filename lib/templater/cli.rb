module Templater
  
  class CLI
    
    def self.run(destination_root, manifold, name, version, arguments)
      
      if arguments.first and not arguments.first =~ /^-/ and not arguments.first == "help"
        generator_name = arguments.shift
        GeneratorCLI.new(generator_name, destination_root, manifold, name, version).run(arguments)
      else
        ManifoldCLI.new(destination_root, manifold, name, version).run(arguments)
      end
    end
    
    def initialize(destination_root, manifold, name, version)
      @manifold = manifold
      @name = name
      @version = version
      @destination_root = destination_root
    end
  
    def version
      puts @version
      exit
    end

  end
  
  class ManifoldCLI < CLI
    
    def run(arguments)
      @options = Templater::Parser.parse(arguments)
      self.help
    end
    
    # outputs a helpful message and quits
    def help
      puts "Usage: #{@name} generator_name [options] [args]"
      puts ''
      puts @manifold.desc
      puts ''
      puts @options[:opts]
      puts ''
      exit
    end
    
  end
  
  class GeneratorCLI < CLI
    
    def initialize(generator_name, *args)
      super(*args)
      @generator_name = generator_name
      @generator_class = @manifold.generator(@generator_name)
    end
    
    # outputs a helpful message and quits
    def help
      puts "Usage: #{@name} #{@generator_name} [options] [args]"
      puts ''
      puts @generator_class.desc
      puts ''
      puts @options[:opts]
      puts ''
      exit
    end
    
    def run(arguments)
      generator_class = @generator_class # FIXME: closure wizardry, there has got to be a better way than this?
      @options = Templater::Parser.parse(arguments) do |opts, options|
        # Loop through this generator's options and add them as valid command line options
        # so that they show up in help messages and such
        generator_class.options.each do |name, settings|
          opts.on("--#{name}", settings[:desc]) do |s|
            options[name] = settings
          end
        end
      end
      
      self.help if @options[:help]
      self.help if arguments.first == 'help'
      self.version if @options[:version]
    
      generator = @generator_class.new(@destination_root, @options, *arguments)
    
      step_through_templates(generator.templates)
    end
    
    def step_through_templates(templates)
      templates.each do |template|
        template.invoke!
        puts "* #{template.destination}"
      end
    end
    
  end
  
end