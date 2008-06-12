module Templater
  
  class Generator
    class << self
      
      attr_accessor :arguments, :options, :template_proxies, :invocations
      
      def arguments; @arguments ||= []; end
      def options; @options ||= {}; end
      def template_proxies; @template_proxies ||= []; end
      def invocations; @invocations ||= []; end
      
      def first_argument(*args); argument(0, *args); end
      def second_argument(*args); argument(1, *args); end
      def third_argument(*args); argument(2, *args); end
      def fourth_argument(*args); argument(3, *args); end

      def desc(text = nil)
        @text = text.realign_indentation if text
        return @text
      end

      def argument(n, name, options={}, &block)
        self.arguments[n] = [name, options, block]
        class_eval <<-CLASS
          def #{name}
            get_argument(#{n})
          end
          
          def #{name}=(arg)
            set_argument(#{n}, arg)
          end
        CLASS
      end
      
      def option(name, options={})
        self.options[name.to_sym] = options
        class_eval <<-CLASS
          def #{name}
            get_option(:#{name})
          end
          
          def #{name}=(arg)
            set_option(:#{name}, arg)
          end
        CLASS
      end
      
      def invoke(name, options={}, &block)
        self.invocations << [name, options, block]
      end
      
      def template(name, *args, &block)
        options = args.last.is_a?(Hash) ? args.pop : {}
        source = args[0]
        destination = args[1]
        source, destination = source + 't', source if destination.nil? and not source.nil?
        
        # note that the proxies are stored as an array of arrays, paired with the passed in options.
        self.template_proxies.push([Templater::TemplateProxy.new(name, source, destination, &block), options])
      end
      
      def list(list)
        list.to_a.each do |item|
          item = item.to_s.chomp.strip
          self.template(item.gsub(/[\.\/]/, '_').to_sym, item)
        end
      end
      
    end
    
    attr_accessor :destination_root, :arguments, :templates
    
    def initialize(destination_root, options = {}, *args)
      # FIXME: options as a second argument is kinda stupid, since it forces silly syntax, but since *args
      # might contain hashes, I can't come up with another way of making this unambiguous. 
      @destination_root = destination_root
      @arguments = []
      @options = options
      
      self.class.options.each do |name, o|
        @options[name] ||= o[:default]
      end
      
      extract_arguments(*args)
      
      valid_arguments?
    end
    
    def template(name)
      self.templates.find {|t| t.name == name }
    end
    
    def templates
      templates = self.class.template_proxies.map { |t| [t[0].to_template(self), t[1]] }
      templates.map! do |t|
        template, template_options = t
        # check to see if either 'all' is true, or if all template option match the generator options
        (template_options.all? {|tok, tov| get_option(tok) == tov }) ? template : nil
      end
      templates.compact
    end
    
    def invocations
      invocations = self.class.invocations.map do |t|
        generator, generator_options, block = t
        args = block ? instance_eval(&block) : @arguments
        # check to see if all options match the generator options
        (generator_options.all? {|tok, tov| get_option(tok) == tov }) ? generator.new(*args) : nil
      end
      invocations.compact
    end
    
    def invoke!
      templates.each { |t| t.invoke! }
    end
    
    def source_root
      raise "Subclasses of Templater::Generator must override the source_root method, to specify where source templates are located."
    end
    
    def destination_root
      @destination_root # just here so it can be documented.
    end
    
    protected
    
    def set_argument(n, arg)
      name, options, block = self.class.arguments[n]
      valid_argument?(arg, options, &block)
      @arguments[n] = arg
    end
    
    def get_argument(n)
      @arguments[n] || self.class.arguments[n][1][:default]
    end
    
    def set_option(name, arg)
      @options[name] = arg
    end
    
    def get_option(name)
      @options[name]
    end
    
    def valid_argument?(arg, options, &block)
      if arg.nil? and options[:required]
        raise Templater::TooFewArgumentsError
      elsif not arg.nil?
        if options[:as] == :hash and not arg.is_a?(Hash)
          raise Templater::MalformattedArgumentError, "Expected the argument to be a Hash, but was '#{arg.inspect}'"
        elsif options[:as] == :array and not arg.is_a?(Array)
          raise Templater::MalformattedArgumentError, "Expected the argument to be an Array, but was '#{arg.inspect}'"
        end
           
        invalid = catch :invalid do
          yield if block_given?
          throw :invalid, :not_invalid
        end
        raise Templater::ArgumentError, invalid unless invalid == :not_invalid
      end
    end
    
    def valid_arguments?
      self.class.arguments.each_with_index do |arg, i|
        name, options, block = arg
        valid_argument?(@arguments[i], options, &block)
      end
    end
    
    def extract_arguments(*args)
      args.each_with_index do |arg, i|      
        name, options, block = self.class.arguments[i]
        raise Templater::TooManyArgumentsError, "This generator does not take this many Arguments" if name.nil?
      
        # When one of the arguments has :as set to :hash or :list, the remaining arguments should be consumed
        # and converted to a Hash or an Array respectively
        case options[:as]
        when :hash
          if arg.is_a?(String)
            pairs = args[i..-1]
            
            hash = pairs.inject({}) do |h, pair|
              key, value = pair.split(':')
              raise Templater::MalformattedArgumentError, "Expected '#{arg.inspect}' to be a key/value pair" unless key and value
              h[key] = value
              h
            end
            
            set_argument(i, hash) and return
          else
            set_argument(i, arg)
          end
        when :array
          set_argument(i, args[i..-1].flatten) and return
        else
          set_argument(i, arg)
        end
      end
    end
  end
  
end