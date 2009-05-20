module Templater

  ACTION_RESERVED_OPTIONS = [:before, :after].freeze

  class Generator

    include Templater::CaptureHelpers

    class << self

      attr_accessor :manifold


      # Returns an array of hashes, where each hash describes a single argument.
      #
      # === Returns
      # Array[Hash{Symbol=>Object}]:: A list of arguments
      def arguments; @arguments ||= []; end

      # A shorthand method for adding the first argument, see +Templater::Generator.argument+
      def first_argument(*args); argument(0, *args); end

      # A shorthand method for adding the second argument, see +Templater::Generator.argument+
      def second_argument(*args); argument(1, *args); end

      # A shorthand method for adding the third argument, see +Templater::Generator.argument+
      def third_argument(*args); argument(2, *args); end

      # A shorthand method for adding the fourth argument, see +Templater::Generator.argument+
      def fourth_argument(*args); argument(3, *args); end


      # Returns an array of options, where each hash describes a single option.
      #
      # === Returns
      # Array[Hash{Symbol=>Object}]:: A list of options
      def options; @options ||= []; end

      
      def recipes; @recipes ||= {} end

      def recipe(name, options=true, &block)
        recipes[name] ||= Description.new(name, options, &block)
        recipes[name].options = options
        recipes[name].block = block if block
      end

      alias_method :use_recipe, :recipe

      # If the argument is omitted, simply returns the description for this generator, otherwise
      # sets the description to the passed string.
      #
      # === Parameters
      # text<String>:: A description
      #
      # === Returns
      # String:: The description for this generator
      def desc(text = nil)
        @text = text.realign_indentation if text
        return @text
      end

      # Assign a name to the n:th argument that this generator takes. An accessor
      # with that name will automatically be added to the generator. Options can be provided
      # to ensure the argument conforms to certain requirements. If a block is provided, when an
      # argument is assigned, the block is called with that value and if :invalid is thrown, a proper
      # error is raised
      #
      # === Parameters
      # n<Integer>:: The index of the argument that this describes
      # name<Symbol>:: The name of this argument, an accessor with this name will be created for the argument
      # options<Hash>:: Options for this argument
      # &block<Proc>:: Is evaluated on assignment to check the validity of the argument
      #
      # ==== Options (opts)
      # :default<Object>:: Specify a default value for this argument
      # :as<Symbol>:: If set to :hash or :array, this argument will 'consume' all remaining arguments and bundle them
      #     Use this only for the last argument to this generator.
      # :required<Boolean>:: If set to true, the generator will throw an error if it initialized without this argument
      # :desc<Symbol>:: Provide a description for this argument
      def argument(n, name, options={}, &block)
        self.arguments[n] = ArgumentDescription.new(name.to_sym, options, &block)
        class_eval <<-CLASS
          def #{name}
            get_argument(#{n})
          end

          def #{name}=(arg)
            set_argument(#{n}, arg)
          end
        CLASS
      end

      # Adds an accessor with the given name to this generator, also automatically fills that value through
      # the options hash that is provided when the generator is initialized.
      #
      # === Parameters
      # name<Symbol>:: The name of this option, an accessor with this name will be created for the option
      # options<Hash>:: Options for this option (how meta!)
      #
      # ==== Options (opts)
      # :default<Object>:: Specify a default value for this option
      # :as<Symbol>:: If set to :boolean provides a hint to the interface using this generator.
      # :desc<Symbol>:: Provide a description for this option
      def option(name, options={})
        self.options << Description.new(name.to_sym, options)
        class_eval <<-CLASS
          def #{name}
            get_option(:#{name})
          end

          def #{name}=(arg)
            set_option(:#{name}, arg)
          end
        CLASS
      end

      # This should return the directory where source templates are located. This method must be overridden in
      # any Generator inheriting from Templater::Source.
      #
      # === Raises
      # Templater::SourceNotSpecifiedError:: Always raises this error, so be sure to override this method.
      def source_root
        raise Templater::SourceNotSpecifiedError, "Subclasses of Templater::Generator must override the source_root method, to specify where source templates are located."
      end

    end # end of eigenclass


    #
    # ==== Instance methods
    #

    attr_accessor :destination_root, :arguments, :options

    # Create a new generator. Checks the list of arguments agains the requirements set using +argument+.
    #
    # === Parameters
    # destination_root<String>:: The destination, where the generated files will be put.
    # options<Hash{Symbol => Symbol}>:: Options given to this generator.
    # *arguments<String>:: The list of arguments. These must match the declared requirements.
    #
    # === Raises
    # Templater::ArgumentError:: If the arguments are invalid
    def initialize(destination_root, options = {}, *args)
      @destination_root = destination_root
      @arguments = []
      @options = options

      # Initialize options to their default values.
      self.class.options.each do |option|
        @options[option.name] ||= option.options[:default]
      end

      args.each_with_index do |arg, n|
        set_argument(n, arg)
      end

      self.class.arguments.each_with_index do |argument, i|
        # Initialize arguments to their default values.
        @arguments[i] ||= argument.options[:default]
        # Check if all arguments are valid.
        argument.valid?(@arguments[i])
      end
    end

    def actions
      actions ||= []
      recipes.each do |r|
        r.invoke!(self)
        actions += r.actions
      end
      actions
    end

    alias_method :all_actions, :actions

    def recipe(name)
      recipes.select { |r| r.name == name }.first
    end

    def invoke_recipe!(name)
      recipe(name).invoke!
    end

    def recipes
      recipes = self.class.recipes.map do |name, description|
        Templater::Recipe.new(self, description.name, description.options, &description.block)
      end
      recipes.select { |r| r.use? }
    end

    def recipe_names
      recipes.map { |r| r.name }
    end

    # Invokes the templates for this generator
    def invoke!
      actions.each { |t| t.invoke! }
    end

    # Renders all actions in this generator. Use this to verify that rendering templates raises no errors.
    #
    # === Returns
    # [String]:: The results of the rendered actions
    def render!
      actions.map { |t| t.render }
    end

    # Returns this generator's source root
    #
    # === Returns
    # String:: The source root of this generator.
    #
    # === Raises
    # Templater::SourceNotSpecifiedError:: IF the source_root class method has not been overridden.
    def source_root
      self.class.source_root
    end

    # Returns the destination root that is given to the generator on initialization. If the generator is a
    # command line program, this would usually be Dir.pwd.
    #
    # === Returns
    # String:: The destination root
    def destination_root
      @destination_root # just here so it can be documented.
    end

    def after_run
      # override in subclasses if necessary
    end

    def after_generation
      # override in subclasses if necessary
    end

    def after_deletion
      # override in subclasses if necessary
    end

  private

    def set_argument(n, value)
      expected = self.class.arguments[n]
      raise Templater::TooManyArgumentsError, "This generator does not take this many Arguments" if expected.nil?

      value = expected.extract(value)

      expected.valid?(value)
      @arguments[n] = value
    end

    def get_argument(n)
      @arguments[n]
    end

    def set_option(name, value)
      @options[name] = value
    end

    def get_option(name)
      @options[name]
    end

    def match_options?(options)
      options.all? do |key, value|
        key.to_sym.in?(Templater::ACTION_RESERVED_OPTIONS) or self.send(key) == value
      end
    end

  end

end
