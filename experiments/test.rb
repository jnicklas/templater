require File.join(File.dirname(__FILE__), *%w[.. lib templater])

class MyGenerator < Templater::Generator

  def self.source_root
    File.join(File.dirname(__FILE__))
  end

  recipe :foo do
    simple_action("dooing a foo") do
      puts "now foo"
    end
    generate StupidGenerator
  end

end

class StupidGenerator < Templater::Generator
  recipe :bar do
    simple_action("doinga a bar") do
      puts "this is BAR!"
    end
  end
end

foo = MyGenerator.new(File.join(File.dirname(__FILE__)))

foo.invoke!