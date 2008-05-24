module Templater
  
  class Generator
    class << self
      
      attr_accessor :arguments
      
      def first_argument(*args); argument(0, *args); end
      def second_argument(*args); argument(1, *args); end
      def third_argument(*args); argument(2, *args); end
      def fourth_argument(*args); argument(3, *args); end

      def argument(n, name, options={}, &block)
        @arguments ||= []
        @arguments[n] = [name, options, block]
        class_eval <<-CLASS
          def #{name}
            get_argument(#{n})
          end
          
          def #{name}=(arg)
            set_argument(#{n}, arg)
          end
        CLASS
      end
      
    end
    
    attr_accessor :arguments
    
    def initialize(*args)
      @arguments = []
      args.each_with_index do |arg, i|
        set_argument(i, arg)
      end
      valid_arguments?
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