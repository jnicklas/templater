module Templater
  
  class Generator
    class << self
      
      attr_accessor :arguments, :options, :template_proxies
      
      def arguments; @arguments ||= []; end
      def options; @options ||= {}; end
      def template_proxies; @template_proxies ||= []; end
      
      def first_argument(*args); argument(0, *args); end
      def second_argument(*args); argument(1, *args); end
      def third_argument(*args); argument(2, *args); end
      def fourth_argument(*args); argument(3, *args); end

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
            @options[:name] || self.class.options[:#{name}][:default]
          end
          
          def #{name}=(set)
            @options[:name] = set
          end
        CLASS
      end
      
      def template(name, options={}, &block)
        # note that the proxies are stored as an array of arrays, paired with the passed in options.
        self.template_proxies.push([Templater::TemplateProxy.new(name, &block), options])
      end
      
    end
    
    attr_accessor :destination_root, :arguments, :templates
    
    def initialize(destination_root, *args)
      @destination_root = destination_root
      @arguments = []
      @options = {}
      # convert the template proxies to actual templates
      @templates = self.class.template_proxies.map { |t| [t[0].to_template(self), t[1]] }
      args.each_with_index do |arg, i|
        set_argument(i, arg)
      end
      valid_arguments?
    end
    
    def template(name)
      @templates.find {|t| t[0].name == name }[0]
    end
    
    def templates
      @templates.map { |t| t[0] }
    end
    
    def invoke!
      templates.each { |t| t.invoke! }
    end
    
    def source_root
      raise "Subclasses of Templater::Generator must override the source_root method, to specify where source templates are located."
    end
    
    protected
    
    def set_argument(n, arg)
      name, options, block = self.class.arguments[n]
      raise Templater::TooManyArgumentsError, "This generator does not take this many Arguments" if name.nil?
      valid_argument?(arg, options, &block)
      @arguments[n] = arg
    end
    
    def get_argument(n)
      @arguments[n]
    end
    
    def valid_argument?(arg, options, &block)
      
      if arg.nil? and options[:required]
        raise Templater::TooFewArgumentsError
      elsif not arg.nil?
        if options[:as] == :hash and not arg.is_a?(Hash)
          raise Templater::MalformattedArgumentError, "Expected the argument to be a hash, but was '#{arg.inspect}'"
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
  end
  
end