require File.join(File.dirname(__FILE__), *%w[.. lib templater])

class MyGenerator < Templater::Generator

  def self.source_root
    File.join(File.dirname(__FILE__))
  end

  recipe :foo do
    simple_action("dooing a foo") do
      puts "now foo"
    end
    template "foo.rb", "bar.rb"
  end

  def bar
    "4 + 4"
  end

end

foo = MyGenerator.new(File.join(File.dirname(__FILE__)))

foo.invoke!