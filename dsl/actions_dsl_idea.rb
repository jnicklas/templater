class MyGenerator
  
  action do |a|
    a.invoke do
      # ...
    end
    a.revoke do
      # ...
    end
  end
  
  # for example, we could implement the 'template' action like this:
  # very simplified:
  def self.template(source, destination)
    action do |a|
      a.invoke do
        throw :identical if File.identical?(source, destination)
        throw :conflict if File.exist?(destination)
        FileUtils.cp(source, destination)
      end
      a.revoke do
        FileUils.rm(destination)
      end
    end
  end
  
  # or git support:
  def self.git(command)
    action do |a|
      a.invoke { `git #{command}` }
    end
  end
  
  # maybe we could allow direct assignment of action like objects
  def self.some_action(foo)
    action SomeClassThatQuacksLikeAnAction.new(foo)
  end
  
end

# We can seperate actions out into modules:
module Templater
  module Actions
    module Git

      def git(command)
        action do |a|
          a.invoke { `git #{command}` }
        end
      end

    end
  end
  
  class Generator
    include Templater::Actions
    include Templater::Actions::Git
  end
end
