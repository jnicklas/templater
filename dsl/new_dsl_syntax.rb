module ActiveRecord
  module Generators
    extend Templater::Manifold

    class Base < ::Templater::Generator
      include Rails::Generator::NamedBase

      protected
        # This is a new action to be called inside the recipe that allows migration.
        #
        def migrate(file_name, destination, options={})
          # ...
        end
    end

    class ModelGenerator < Base
      # This argument is required and it can be given as a positional argument
      # the generator could be invoked like this:
      #
      #   script/generate model --name User
      #   script/generate model User
      #
      argument :name do |a|
        a.description = "Name of the generator"
        a.validate {|name| name !~ /\s/ }
        a.filter {|name| name.camelize! }
      end

      # This argument can be given as a hash:
      #
      #   script/generate model User name:string email:string
      #
      # No more required arguments can be given after it.
      #
      argument :attributes, :hash => true, :description => "Model attributes"

      option :skip_migration, :boolean => true
      option :skip_timestamps, :boolean => true

      before :check_class_collisions

      recipe :model do
        directory File.join("app/models", class_path)
        template 'model.rb', File.join("app/models", class_path, "#{file_name}.rb")
      end

      # The reason this is a recipe and it's not invoking the migration generator
      # is because they are very different. We can have migrations that is not
      # necessary related with creating a model.
      recipe :migration, :unless => :skip_migration? do
        directory File.join("db", "migrate")
        migration class_underscore_name, File.join("db", "migrate"), :up => up_content_for_migration, :down => down_content_for_migration
      end

      protected
        def skip_migration?
          @options.key?(:skip_migration)
        end

        def up_content_for_migration
          # ...
        end

        def down_content_for_migration
          # ...
        end
    end

    # Register this generator. It can be invoked in two ways:
    #
    #   ActiveRecord::Generators::ModelGenerator.call(options)
    #
    # Or with the alias name, using templater interface:
    #
    #   Templater::Generators[:activerecord].call(options)
    #
    add :activerecord, ModelGenerator

  end
end