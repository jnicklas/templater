module Templater
  
  module CLI
  
    class Manifold

      def initialize(destination_root, manifold, name, version)
        @destination_root, @manifold, @name, @version = destination_root, manifold, name, version
      end

      def version
        puts @version
        exit
      end

      def self.run(destination_root, manifold, name, version, arguments)

        if arguments.first and not arguments.first =~ /^-/ and not arguments.first == "help"
          generator_name = arguments.shift
          if generator_class = manifold.generator(generator_name)
            Generator.new(generator_name, generator_class, destination_root, name, version).run(arguments)
          else
            Manifold.new(destination_root, manifold, name, version).run(arguments)
          end
        else
          Manifold.new(destination_root, manifold, name, version).run(arguments)
        end
      end

      def run(arguments)
        @options = Templater::CLI::Parser.parse(arguments)
        self.help
      end

      # outputs a helpful message and quits
      def help
        puts "Usage: #{@name} generator_name [options] [args]"
        puts ''
        puts @manifold.desc
        puts ''
        puts 'Available Generators'
        @manifold.public_generators.each do |name, generator|
          print "    "
          print name.to_s.ljust(33)
          print generator.desc.to_a.first.chomp if generator.desc
          print "\n"
        end
        puts @options[:opts]
        puts ''
        exit
      end

    end
    
  end
  
end