module Templater
  
  class Generator
    
    include Templater::CaptureHelpers
    
    class << self
      
      attr_accessor :manifold
      
      # Returns an array of hashes, where each hash describes a single argument.
      #
      # === Returns
      # Array[Hash{Symbol=>Object}]:: A list of arguments
      def arguments; @arguments ||= []; end
      
      # Returns an array of options, where each hash describes a single option.
      #
      # === Returns
      # Array[Hash{Symbol=>Object}]:: A list of options
      def options; @options ||= []; end
      
      # Returns an array of hashes, where each hash describes a single template.
      #
      # === Returns
      # Array[Hash{Symbol=>Object}]:: A list of template
      def templates; @templates ||= []; end
      
      # Returns an array of hashes, where each hash describes a single file.
      #
      # === Returns
      # Array[Hash{Symbol=>Object}]:: A list of files
      def files; @files ||= []; end
      
      # Returns an array of hashes, where each hash describes a single invocation.
      #
      # === Returns
      # Array[Hash{Symbol=>Object}]:: A list of invocations
      def invocations; @invocations ||= []; end
      
      # A shorthand method for adding the first argument, see +Templater::Generator.argument+
      def first_argument(*args); argument(0, *args); end

      # A shorthand method for adding the second argument, see +Templater::Generator.argument+
      def second_argument(*args); argument(1, *args); end

      # A shorthand method for adding the third argument, see +Templater::Generator.argument+
      def third_argument(*args); argument(2, *args); end
      
      # A shorthand method for adding the fourth argument, see +Templater::Generator.argument+
      def fourth_argument(*args); argument(3, *args); end

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
      
      # Adds an invocation of another generator to this generator. This allows the interface to invoke
      # any templates in that target generator. This requires that the generator is part of a manifold. The name
      # provided is the name of the target generator in this generator's manifold.
      #
      # A hash of options can be passed, all of these options are matched against the options passed to the
      # generator.
      #
      # If a block is given, the generator class is passed to the block, and it is expected that the
      # block yields an instance. Otherwise the target generator is instantiated with the same options and
      # arguments as this generator.
      #
      # === Parameters
      # name<Symbol>:: The name in the manifold of the generator that is to be invoked
      # options<Hash>:: A hash of requirements that are matched against the generator options
      # &block<Proc>:: A block to execute when the generator is instantiated
      #
      # ==== Examples
      #
      #   class MyGenerator < Templater::Generator
      #     invoke :other_generator
      #   end
      #
      #   class MyGenerator < Templater::Generator
      #     def random
      #       rand(100000).to_s
      #     end
      #
      #     # invoke :other_generator with some 
      #     invoke :other_generator do |generator|
      #       generator.new(destination_root, options, random)
      #     end
      #   end
      #   
      #   class MyGenerator < Templater::Generator
      #     option :animal
      #     # other_generator will be invoked only if the option 'animal' is set to 'bear'
      #     invoke :other_generator, :amimal => :bear
      #   end
      def invoke(name, options={}, &block)
        self.invocations << {
          :name => name,
          :options => options,
          :block => block
        }
      end
      
      # Adds a template to this generator. Templates are named and can later be retrieved by that name.
      # Templates have a source and a destination. When a template is invoked, the source file is rendered,
      # passing through ERB, and the result is copied to the destination. Source and destination can be
      # specified in different ways, and are always assumed to be relative to source_root and destination_root.
      #
      # If only a destination is given, the source is assumed to be the same destination, only appending the
      # letter 't', so a destination of 'app/model.rb', would assume a source of 'app/model.rbt'
      #
      # Source and destination can be set in a block, which makes it possible to call instance methods to
      # determine the correct source and/or desination.
      #
      # A hash of options can be passed, all of these options are matched against the options passed to the
      # generator.
      #
      # === Parameters
      # name<Symbol>:: The name of this template
      # source<String>:: The source template, can be omitted
      # destination<String>:: The destination where the result will be put.
      # options<Hash>:: Options for this template
      # &block<Proc>:: A block to execute when the generator is instantiated
      #
      # ==== Examples
      #
      #   class MyGenerator < Templater::Generator
      #     def random
      #       rand(100000).to_s
      #     end
      #
      #     template :one, 'template.rb' # source will be inferred as 'template.rbt'
      #     template :two, 'source.rbt', 'template.rb' # source expicitly given
      #     template :three do
      #       source('source.rbt')
      #       destination("#{random}.rb")
      #     end
      #   end
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
      
      # Adds a template that is not rendered using ERB, but copied directly. Unlike Templater::Generator.template
      # this will not append a 't' to the source, otherwise it works identically.
      #
      # === Parameters
      # name<Symbol>:: The name of this template
      # source<String>:: The source template, can be omitted
      # destination<String>:: The destination where the result will be put.
      # options<Hash>:: Options for this template
      # &block<Proc>:: A block to execute when the generator is instantiated
      def file(name, *args, &block)
        options = args.last.is_a?(Hash) ? args.pop : {}
        source, destination = args
        source, destination = source, source if args.size == 1
        
        self.files << {
          :name => name,
          :options => options,
          :source => source,
          :destination => destination,
          :block => block,
          :render => false
        }
      end
                       
      # An easy way to add many templates to a generator, each item in the list is added as a
      # template. The provided list can be either an array of Strings or a Here-Doc with templates
      # on individual lines.
      #
      # === Parameters
      # list<String|Array>:: A list of templates to be added to this generator
      # 
      # === Examples
      #
      #   class MyGenerator < Templater::Generator
      #     template_list <<-LIST
      #       path/to/template1.rb
      #       another/template.css
      #     LIST
      #     template_list ['a/third/template.rb', 'and/a/fourth.js']
      #   end 
      def template_list(list)
        list.to_a.each do |item|
          item = item.to_s.chomp.strip
          self.template(item.gsub(/[\.\/]/, '_').to_sym, item)
        end
      end
      
      # An easy way to add many non-rendering templates to a generator. The provided list can be either an
      # array of Strings or a Here-Doc with templates on individual lines.
      #
      # === Parameters
      # list<String|Array>:: A list of non-rendering templates to be added to this generator
      # 
      # === Examples
      #
      #   class MyGenerator < Templater::Generator
      #     file_list <<-LIST
      #       path/to/file.jpg
      #       another/file.html.erb
      #     LIST
      #     file_list ['a/third/file.gif', 'and/a/fourth.rb']
      #   end
      def file_list(list)
        list.to_a.each do |item|
          item = item.to_s.chomp.strip
          self.file(item.gsub(/[\.\/]/, '_').to_sym, item)
        end
      end
      
      # Search a directory for templates and files and add them to this generator. Any file
      # whose extension matches one of those provided in the template_extensions parameter
      # is considered a template and will be rendered with ERB, all others are considered
      # normal files and are simply copied.
      # 
      # A hash of options can be passed which will be assigned to each file and template.
      # All of these options are matched against the options passed to the generator.
      #
      # === Parameters
      # source<String>:: The directory to search in.
      # template_destination<Array[String]>:: A list of extensions. If a file has one of these
      #     extensions, it is considered a template and will be rendered with ERB.
      # options<Hash{Symbol=>Object}>:: A list of options.
      def glob!(source, template_extensions = %w(rb css js erb html yml), options={})
        ::Dir[::File.join(source, '*')].each do |action|
          if template_extensions.include?(::File.extname(action)[1..-1])
            template(action.gsub(/[^a-z0-9]+/, '_').to_sym, action, action)
          else
            file(action.gsub(/[^a-z0-9]+/, '_').to_sym, action, action)
          end
        end
      end
      
      # Returns a list of the classes of all generators (recursively) that are invoked together with this one.
      # 
      # === Returns
      # Array[Templater::Generator]:: an array of generator classes.
      def generators
        if manifold
          generators = invocations.map do |i|
            generator = manifold.generator(i[:name])
            generator ? generator.generators : nil
          end
          generators.unshift(self).flatten.compact
        else
          [self]
        end
      end
      
    end
    
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
    
    # Finds and returns the template of the given name. If that template's options don't match the generator
    # options, returns nil.
    #
    # === Parameters
    # name<Symbol>:: The name of the template to look up.
    #
    # === Returns
    # Templater::Template:: The found template.
    def template(name)
      self.templates.find { |t| t.name == name }
    end
    
    # Finds and returns the file of the given name. If that file's options don't match the generator
    # options, returns nil.
    #
    # === Parameters
    # name<Symbol>:: The name of the file to look up.
    #
    # === Returns
    # Templater::File:: The found file.
    def file(name)
      self.files.find { |f| f.name == name }
    end
    
    # Finds and returns all templates whose options match the generator options.
    #
    # === Returns
    # [Templater::Template]:: The found templates.
    def templates
      templates = self.class.templates.map do |t|
        template = Templater::TemplateProxy.new(t[:name], t[:source], t[:destination], &t[:block]).to_template(self)
        match_options?(t[:options]) ? template : nil
      end
      templates.compact
    end
    
    # Finds and returns all files whose options match the generator options.
    #
    # === Returns
    # [Templater::File]:: The found files.
    def files
      files = self.class.files.map do |t|
        file = Templater::FileProxy.new(t[:name], t[:source], t[:destination], &t[:block]).to_file(self)
        match_options?(t[:options]) ? file : nil
      end
      files.compact
    end
    
    # Finds and returns all templates whose options match the generator options.
    #
    # === Returns
    # [Templater::Generator]:: The found templates.
    def invocations
      if self.class.manifold
        invocations = self.class.invocations.map do |invocation|
          generator = self.class.manifold.generator(invocation[:name])
          if generator and invocation[:block]
            instance_exec(generator, &invocation[:block])
          elsif generator and match_options?(invocation[:options])
            generator.new(destination_root, options, *@arguments)
          end
        end
        invocations.compact
      else
        []
      end
    end
    
    # Finds and returns all templates and files for this generators and any of those generators it invokes,
    # whose options match that generator's options.
    #
    # === Returns
    # [Templater::File, Templater::Template]:: The found templates and files.
    def actions
      actions = templates + files
      actions += invocations.map { |i| i.actions }
      actions.flatten
    end
    
    # Invokes the templates for this generator
    def invoke!
      templates.each { |t| t.invoke! }
    end
    
    # This should return the directory where source templates are located. This method must be overridden in
    # any Generator inheriting from Templater::Source.
    #
    # === Raises
    # Templater::SourceNotSpecifiedError:: Always raises this error, so be sure to override this method.
    def source_root
      raise Templater::SourceNotSpecifiedError, "Subclasses of Templater::Generator must override the source_root method, to specify where source templates are located."
    end
    
    # Returns the destination root that is given to the generator on initialization. If the generator is a
    # command line program, this would usually be Dir.pwd.
    #
    # === Returns
    # String:: The destination root
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
    
    def match_options?(options)
      options.all? { |key, value| get_option(key) == value }
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

    # from a list of arguments, walk through that list and assign it to this generator, taking into account
    # that an argument could be a hash or array that consumes the remaining arguments.
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