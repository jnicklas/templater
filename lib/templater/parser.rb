require 'optparse'
require 'optparse/time'
require 'ostruct'

module Templater

  class Parser

    def self.parse(args, name = 'bin/templater', version = Templater::VERSION)
      # The options specified on the command line will be collected in *options*.
      # We set default values here.
      options = OpenStruct.new
      options.pretend = false
      options.force = false
      options.skip = false
      options.quiet = false
      options.verbose = false


      opts = OptionParser.new do |opts|
        opts.banner = "Usage: #{name} generator_name [options] [args]"

        if block_given?
          opts.separator ""
          opts.separator "Options specific for this generator:"
          
          yield opts, options
        end

        opts.separator ""
        opts.separator "General options:"

        opts.on("-p", "--pretend", "Run, but do not make any changes.") do |s|
          options.skip = s
        end

        opts.on("-f", "--force", "Overwrite files that already exist.") do |s|
          options.skip = s
        end

        opts.on("-s", "--skip", "Skip files that already exist.") do |s|
          options.skip = s
        end

        opts.on("-q", "--quiet", "Suppress normal output.") do |q|
          options.quit = q
        end

        opts.on("-v", "--verbose", "Run verbosely") do |v|
          options.verbose = v
        end

        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit
        end
      
        opts.on_tail("--version", "Show the version") do
          puts version
          exit
        end

      end

      opts.parse!(args)
      options
    end  # parse()

  end  # class OptparseExample

end