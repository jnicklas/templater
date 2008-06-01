require 'optparse'
require 'optparse/time'

module Templater

  class Parser

    def self.parse(args)
      # The options specified on the command line will be collected in *options*.
      # We set default values here.
      options = {}
      options[:pretend] = false
      options[:force] = false
      options[:skip] = false
      options[:quiet] = false
      options[:verbose] = false
      options[:help] = false
      options[:version] = false

      opts = OptionParser.new do |opts|

        opts.banner = ""

        if block_given?
          opts.separator "Options specific for this generator:"
          
          yield opts, options
        end

        opts.separator "General options:"

        opts.on("-p", "--pretend", "Run, but do not make any changes.") do |s|
          options[:skip] = s
        end

        opts.on("-f", "--force", "Overwrite files that already exist.") do |s|
          options[:skip] = s
        end

        opts.on("-s", "--skip", "Skip files that already exist.") do |s|
          options[:skip] = s
        end

        opts.on("-q", "--quiet", "Suppress normal output.") do |q|
          options[:quit] = q
        end

        opts.on("-v", "--verbose", "Run verbosely") do |v|
          options[:verbose] = v
        end

        opts.on("-h", "--help", "Show this message") do
          options[:help] = true
        end
      
        opts.on("--version", "Show the version") do
          options[:version] = true
        end

      end
      
      def opts.inspect; "<#OptionParser #{object_id}>"; end
      
      options[:opts] = opts

      opts.parse!(args)
      options
    end  # parse()

  end  # class OptparseExample

end