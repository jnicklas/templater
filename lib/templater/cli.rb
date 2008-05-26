module Templater
  
  module CLI
    
    class << self
    
      def run(destination_root, manifold, name, version, arguments)
        @manifold = manifold
        @name = name
        @version = version
        @destination_root = destination_root
        # check to see if the first argument is blank
        if arguments.first and not arguments.first =~ /^-/ and not arguments.first == "help"
          generator_class = manifold.generator(ARGV.first)
          
          @options = Templater::Parser.parse(arguments) do |opts, options|
            # Loop through this generator's options and add them as valid command line options
            # so that they show up in help messages and such
            generator_class.options.each do |name, settings|
              opts.on("--#{name}", settings[:desc]) do |s|
                options[name] = settings
              end
            end
          end
          
          self.help if @options.help
          self.help if arguments.first == 'help'
          self.version if @options.version
          
          generator = generator_class.new(destination_root, *arguments)
          
          step_through_templates(generator.templates)
        else
          @options = Templater::Parser.parse(arguments) 
          help
        end

      end
      
      def step_through_templates(templates)
        templates.each do |template|
          template.invoke!
          puts "* #{template.destination}"
        end
      end
      
      # outputs a helpful message and quits
      def help
        puts "Usage: #{@name} generator_name [options] [args]"
        puts ''
        puts @manifold.desc
        puts ''
        puts @options.opts
        puts ''
        exit
      end
      
      def version
        puts @version
        exit
      end
    
      def invoke(generator, options, arguments)
      
      end
    
    end
    
  end
  
end