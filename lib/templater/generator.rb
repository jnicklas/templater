module Templater
  
  class Generator
    
    include Templater::CaptureHelpers
    
    class << self
      
      attr_accessor :arguments, :options, :template_proxies, :invocations
      
      def arguments; @arguments ||= []; end
      def options; @options ||= []; end
      def templates; @templates ||= []; end
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
        self.arguments[n] = {
          :name => name,
          :options => options,
          :block => block
        }
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
        self.options << {
          :name => name.to_sym,
          :options => options
        }
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
        self.invocations << {
          :name => name,
          :options => options,
          :block => block
        }
      end
      
      def template(name, *args, &block)
        options = args.last.is_a?(Hash) ? args.pop : {}
        source, destination = args
        source, destination = source + 't', source if args.size == 1
        
        self.templates << {
          :name => name,
          :options => options,
          :source => source,
          :destination => destination,
          :block => block,
          :render => true
        }
      end
      
      def file(name, *args, &block)
        options = args.last.is_a?(Hash) ? args.pop : {}
        source, destination = args
        source, destination = source, source if args.size == 1
        
        self.templates << {
          :name => name,
          :options => options,
          :source => source,
          :destination => destination,
          :block => block,
          :render => false
        }
      end
      
      def template_list(list)
        list.to_a.each do |item|
          item = item.to_s.chomp.strip
          self.template(item.gsub(/[\.\/]/, '_').to_sym, item)
        end
      end
      
      def file_list(list)
        list.to_a.each do |item|
          item = item.to_s.chomp.strip
          self.file(item.gsub(/[\.\/]/, '_').to_sym, item)
        end
      end
      
    end
    
    attr_accessor :destination_root, :arguments, :templates, :options
    
    def initialize(destination_root, options = {}, *args)
      # FIXME: options as a second argument is kinda stupid, since it forces silly syntax, but since *args
      # might contain hashes, I can't come up with another way of making this unambiguous. 
      @destination_root = destination_root
      @arguments = []
      @options = options
      
      self.class.options.each do |option|
        @options[option[:name]] ||= option[:options][:default]
      end
      
      extract_arguments(*args)
      
      valid_arguments?
    end
    
    def template(name)
      self.templates.find {|t| t.name == name }
    end
    
    def templates
      templates = self.class.templates.map do |t|
        template = Templater::TemplateProxy.new(t[:name], t[:source], t[:destination], t[:render], &t[:block]).to_template(self)
        # check to see if either 'all' is true, or if all template option match the generator options
        (t[:options].all? {|tok, tov| get_option(tok) == tov }) ? template : nil
      end
      templates.compact
    end
    
    def invocations
      invocations = self.class.invocations.map do |invocation|
        args = invocation[:block] ? instance_eval(&invocation[:block]) : @arguments
        # check to see if all options match the generator options
        (invocation[:options].all? {|tok, tov| get_option(tok) == tov }) ? invocation[:name].new(destination_root, options, *args) : nil
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
      argument = self.class.arguments[n]
      valid_argument?(arg, argument[:options], &argument[:block])
      @arguments[n] = arg
    end
    
    def get_argument(n)
      @arguments[n] || self.class.arguments[n][:options][:default]
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
        valid_argument?(@arguments[i], arg[:options], &arg[:block])
      end
    end
    
    def extract_arguments(*args)
      args.each_with_index do |arg, i|
        expected = self.class.arguments[i]
        raise Templater::TooManyArgumentsError, "This generator does not take this many Arguments" if expected.nil?
      
        # When one of the arguments has :as set to :hash or :list, the remaining arguments should be consumed
        # and converted to a Hash or an Array respectively
        case expected[:options][:as]
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