require File.join(File.dirname(__FILE__), *%w[.. lib templater])

class MyGenerator < Templater::Generator

  def self.source_root
    File.join(File.dirname(__FILE__))
  end

  recipe :foo do
    simple_action("foo action") do
      puts "now foo"
    end
    template "foo.rb", "quog.rb"
    generate StupidGenerator
  end

  def monkey
    "MONKEY!"
  end

end

class StupidGenerator < Templater::Generator
  recipe :bar do
    simple_action("bar action") do
      puts "this is BAR!"
    end
  end
end

foo = MyGenerator.new(File.join(File.dirname(__FILE__)))

#foo.invoke!
foo.actions.each do |action|
  puts "[#{action.status}] #{action.description}"
  action.invoke!
end