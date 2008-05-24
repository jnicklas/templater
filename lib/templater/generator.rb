module Templater
  
  class Generator
    class << self
      
      attr_accessor :arguments
      
      def first_argument(*args); argument(0, *args); end
      def second_argument(*args); argument(1, *args); end
      def third_argument(*args); argument(2, *args); end
      def fourth_argument(*args); argument(3, *args); end
      def fifth_argument(*args); argument(4, *args); end
      def sixth_argument(*args); argument(5, *args); end

      def argument(n, name, options={})
        @arguments ||= []
        @arguments[n] = [name, :options => options]
        # Note that @arguments in the eval is not the same as the above @arguments!
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
      args.each_with_index do |arg, i|
        set_argument(i, arg)
      end
    end
    
    protected
    
    def set_argument(n, arg)
      name, options = self.class.arguments[n]
      raise Templater::TooManyArgumentsError, "This generator does not take this many Arguments" if name.nil? or options.nil?
      if options[:as] == :hash
        raise Templater::MalformedArgumentError, "Expected the argument to be a hash, but was #{arg}" unless arg.is_a?(Hash)
      end
      @arguments[n] = arg
    end
    
    def get_argument(n)
      @arguments[n]
    end
  end
  
end