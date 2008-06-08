require File.dirname(__FILE__) + '/spec_helper'

describe Templater::Generator, '#desc' do

  it "should append text when called with an argument, and return it when called with no argument" do
    @generator_class = Class.new(Templater::Generator)
    
    @generator_class.desc "some text"
    @generator_class.desc.should == "some text"
  end

end

describe Templater::Generator, '.argument' do

  before do
    @generator_class = Class.new(Templater::Generator)
  end
  
  it "should create accessors" do
    @generator_class.argument(0, :monkey)
    
    instance = @generator_class.new('/tmp')
    instance.monkey = 'a test'
    instance.monkey.should == 'a test'
  end
  
  it "should pass an initial value to the argument" do
    @generator_class.argument(0, :monkey)
    
    instance = @generator_class.new('/tmp', {}, 'i am a monkey')
    instance.monkey.should == 'i am a monkey'
  end
  
  it "should create multiple accessors" do
    @generator_class.argument(0, :monkey)
    @generator_class.argument(1, :llama)
    @generator_class.argument(2, :herd)
    
    instance = @generator_class.new('/tmp')
    instance.monkey = 'a monkey'
    instance.monkey.should == 'a monkey'
    instance.llama = 'a llama'
    instance.llama.should == 'a llama'
    instance.herd = 'a herd'
    instance.herd.should == 'a herd'
  end
  
  it "should pass an initial value to multiple accessors" do
    @generator_class.argument(0, :monkey)
    @generator_class.argument(1, :llama)
    @generator_class.argument(2, :herd)
    
    instance = @generator_class.new('/tmp', {}, 'a monkey', 'a llama', 'a herd')
    instance.monkey.should == 'a monkey'
    instance.llama.should == 'a llama'
    instance.herd.should == 'a herd'
  end
  
  it "should set a default value for an argument" do
    @generator_class.argument(0, :monkey, :default => 'a revision')
    
    instance = @generator_class.new('/tmp')
    instance.monkey.should == 'a revision'
  end
  
  it "should allow some syntactic sugar declaration" do
    @generator_class.first_argument(:monkey)
    @generator_class.second_argument(:llama)
    @generator_class.third_argument(:herd)
    @generator_class.fourth_argument(:elephant)
    
    instance = @generator_class.new('/tmp', {}, 'a monkey', 'a llama', 'a herd', 'an elephant')
    instance.monkey.should == 'a monkey'
    instance.llama.should == 'a llama'
    instance.herd.should == 'a herd'
    instance.elephant.should == 'an elephant'
  end
  
  it "should whine when there are too many arguments" do
    @generator_class.argument(0, :monkey)
    @generator_class.argument(1, :llama)
    
    lambda { @generator_class.new('/tmp', {}, 'a monkey', 'a llama', 'a herd') }.should raise_error(Templater::TooManyArgumentsError)
  end
  
  it "should assign arguments if an argument is required and that requirement is fullfilled" do
    @generator_class.argument(0, :monkey, :required => true)
    @generator_class.argument(1, :elephant, :required => true)
    @generator_class.argument(2, :llama)
    
    instance = @generator_class.new('/tmp', {}, 'enough', 'arguments')
    instance.monkey.should == "enough"
    instance.elephant.should == "arguments"
    instance.llama.should be_nil
  end
  
  it "should raise an error when a required argument is not passed" do
    @generator_class.argument(0, :monkey, :required => true)
    @generator_class.argument(1, :elephant, :required => true)
    @generator_class.argument(2, :llama)
    
    lambda { @generator_class.new('/tmp', {}, 'too few arguments') }.should raise_error(Templater::TooFewArgumentsError)    
  end
  
  it "should raise an error if nil is assigned to a require argument" do
    @generator_class.argument(0, :monkey, :required => true)
    
    instance = @generator_class.new('/tmp', {}, 'test')
    
    lambda { instance.monkey = nil }.should raise_error(Templater::TooFewArgumentsError)    
  end
  
  it "should assign an argument when a block appended to an argument does not throw :invalid" do
    @generator_class.argument(0, :monkey) do
      1 + 1
    end
    @generator_class.argument(1, :elephant) do
      false
    end
    @generator_class.argument(2, :llama)
    
    instance = @generator_class.new('/tmp', {}, 'blah', 'urgh')
    instance.monkey.should == 'blah'
    instance.elephant.should == 'urgh'
    
    instance.monkey = :harr
    instance.monkey.should == :harr
  end
  
  it "should raise an error with the throw message, when a block is appended to an argument and throws :invalid" do
    @generator_class.argument(0, :monkey) do
      throw :invalid, 'this is not a valid monkey, bad monkey!'
    end
    
    lambda { @generator_class.new('/tmp', {}, 'blah') }.should raise_error(Templater::ArgumentError, 'this is not a valid monkey, bad monkey!')
    
    instance = @generator_class.new('/tmp')
    
    lambda { instance.monkey = :anything }.should raise_error(Templater::ArgumentError, 'this is not a valid monkey, bad monkey!')
  end

end

describe Templater::Generator, '.argument as hash' do

  before do
    @generator_class = Class.new(Templater::Generator)
    @generator_class.argument(0, :monkey)
    @generator_class.argument(1, :llama, :as => :hash)
  end
  
  it "should allow assignment of hashes" do
    instance = @generator_class.new('/tmp', {}, 'a monkey', { :hash => 'blah' })
    
    instance.monkey.should == 'a monkey'
    instance.llama[:hash].should == 'blah'
    
    instance.llama = { :me_s_a => :hash }
    instance.llama[:me_s_a].should == :hash
  end
  
  it "should convert a key/value pair to a hash" do
    instance = @generator_class.new('/tmp', {}, 'a monkey', 'test:unit')
    instance.llama['test'].should == 'unit'
  end
  
  it "should consume the remaining arguments and convert them to a hash if they are key/value pairs" do
    instance = @generator_class.new('/tmp', {}, 'a monkey', 'test:unit', 'john:silver', 'river:road')
    instance.llama['test'].should == 'unit'
    instance.llama['john'].should == 'silver'
    instance.llama['river'].should == 'road'
  end
  
  it "should raise an error if one of the remaining arguments is not a key/value pair" do
    lambda { @generator_class.new('/tmp', {}, 'a monkey', 'a:llama', 'duck:llama', 'not_a_pair', 'pair:blah') }.should raise_error(Templater::MalformattedArgumentError)
  end
  
  it "should raise error if the argument is neither a hash nor a key/value pair" do
    lambda { @generator_class.new('/tmp', {}, 'a monkey', 23) }.should raise_error(Templater::MalformattedArgumentError)
    instance = @generator_class.new('/tmp')
    lambda { instance.llama = :not_a_hash }.should raise_error(Templater::MalformattedArgumentError)
  end

end

describe Templater::Generator, '.argument as array' do

  before do
    @generator_class = Class.new(Templater::Generator)
    @generator_class.argument(0, :monkey)
    @generator_class.argument(1, :llama, :as => :array)
  end
  
  it "should allow assignment of arrays" do
    instance = @generator_class.new('/tmp', {}, 'a monkey', %w(an array))
    
    instance.monkey.should == 'a monkey'
    instance.llama[0].should == 'an'
    instance.llama[1].should == 'array'
    
    instance.llama = %w(another donkey)
    instance.llama[0].should == 'another'
    instance.llama[1].should == 'donkey'
  end
  
  it "should convert a single argument to an array" do
    instance = @generator_class.new('/tmp', {}, 'a monkey', 'test')
    instance.llama[0].should == 'test'
  end
  
  it "should consume the remaining arguments and convert them to an array" do
    instance = @generator_class.new('/tmp', {}, 'a monkey', 'test', 'silver', 'river')
    instance.llama[0].should == 'test'
    instance.llama[1].should == 'silver'
    instance.llama[2].should == 'river'
  end
  
  it "should raise error if the argument is not an array" do
    instance = @generator_class.new('/tmp')
    lambda { instance.llama = :not_an_array }.should raise_error(Templater::MalformattedArgumentError)
  end

end

describe Templater::Generator, '.template' do

  before do
    @generator_class = Class.new(Templater::Generator)
  end

  it "should add a template with source and destination" do
    @generator_class.template(:my_template, 'path/to/souce.rbt', 'path/to/destination.rb')
    @instance = @generator_class.new('/tmp/destination')
    
    @instance.stub!(:source_root).and_return('/tmp/source')
    
    @instance.template(:my_template).source = '/tmp/source/path/to/source.rbt'
    @instance.template(:my_template).destination = '/tmp/destination/path/to/destination.rb'
  end
  
  it "should add a template with destination and infer the source" do
    @generator_class.template(:my_template, 'path/to/destination.rb')
    @instance = @generator_class.new('/tmp/destination')
    
    @instance.stub!(:source_root).and_return('/tmp/source')
    
    @instance.template(:my_template).source = '/tmp/source/path/to/destination.rbt'
    @instance.template(:my_template).destination = '/tmp/destination/path/to/destination.rb'
  end
  
  it "should add a template with a block" do
    @generator_class.template(:my_template) do
      source 'blah.rbt'
      destination "gurr#{Process.pid.to_s}.rb"
    end
    @instance = @generator_class.new('/tmp/destination')
    
    @instance.stub!(:source_root).and_return('/tmp/source')
    
    @instance.template(:my_template).source = '/tmp/source/blah.rbt'
    @instance.template(:my_template).destination = "/tmp/destination/gurr#{Process.pid.to_s}.rb"
  end
  
end

describe Templater::Generator, '.invoke' do

  before do
    @generator_class = Class.new(Templater::Generator)
    @generator_class.first_argument :test1
    @generator_class.second_argument :test2
  end

  it "with no block should add an array passing along own arguments" do
    @generator_class.invoke(:migration)
    @instance = @generator_class.new('/tmp', {}, 'test', 'argument')
    
    @instance.invocations[0].should == [:migration, 'test', 'argument']
  end
  
  it "with a block should append the results of the block" do
    @generator_class.invoke(:migration) do
      ['blah', 'monkey', some_method]
    end
    @instance = @generator_class.new('/tmp', {}, 'test', 'argument')
    @instance.should_receive(:some_method).and_return('da')
    
    @instance.invocations[0].should == [:migration, 'blah', 'monkey', 'da']
  end
  
end

describe Templater::Generator, '.list' do
  
  it "should add a series of templates given a list as heredoc" do
    @generator_class = Class.new(Templater::Generator)
    
    @generator_class.should_receive(:template).with(:app_model_rb, 'app/model.rb')
    @generator_class.should_receive(:template).with(:spec_model_rb, 'spec/model.rb')
    @generator_class.should_receive(:template).with(:donkey_poo_css, 'donkey/poo.css')
    @generator_class.should_receive(:template).with(:john_smith_file_rb, 'john/smith/file.rb')
    
    @generator_class.list <<-LIST
      app/model.rb
      spec/model.rb
      donkey/poo.css
      john/smith/file.rb
    LIST
  end
  
  it "should add a series of templates given a list as array" do
    @generator_class = Class.new(Templater::Generator)
    
    @generator_class.should_receive(:template).with(:app_model_rb, 'app/model.rb')
    @generator_class.should_receive(:template).with(:spec_model_rb, 'spec/model.rb')
    @generator_class.should_receive(:template).with(:donkey_poo_css, 'donkey/poo.css')
    @generator_class.should_receive(:template).with(:john_smith_file_rb, 'john/smith/file.rb')
    
    @generator_class.list(%w(app/model.rb spec/model.rb donkey/poo.css john/smith/file.rb))
  end
  
end

describe Templater::Generator, '.option' do

  before do
    @generator_class = Class.new(Templater::Generator)
  end

  it "should add accessors" do
    @generator_class.option(:test)

    instance = @generator_class.new('/tmp')
    
    instance.test = "monkey"
    instance.test.should == "monkey"
    
  end
  
  it "should preset a default value" do
    @generator_class.option(:test, :default => 'elephant')

    instance = @generator_class.new('/tmp')
  
    instance.test.should == "elephant"  
  end
  
  it "should allow overwriting of default values" do
    @generator_class.option(:test, :default => 'elephant')

    instance = @generator_class.new('/tmp')
  
    instance.test.should == "elephant"  
    instance.test = "monkey"  
    instance.test.should == "monkey"  
  end
  
  it "should allow passing in of options on generator creation" do
    @generator_class.option(:test, :default => 'elephant')

    instance = @generator_class.new('/tmp', { :test => 'freebird' })
  
    instance.test.should == "freebird"  
    instance.test = "monkey"  
    instance.test.should == "monkey"  
  end
end

describe Templater::Generator, '#template' do

  before do
    @generator_class = Class.new(Templater::Generator)
    @generator_class.class_eval do
      def source_root
        '/tmp/source'
      end
    end
  end

  it "should find a template by name" do
    @generator_class.template(:blah1, 'blah.rb')
    @generator_class.template(:blah2, 'blah2.rb')
    
    instance = @generator_class.new('/tmp')
    
    instance.template(:blah1).name.should == :blah1
    instance.template(:blah1).source.should == '/tmp/source/blah.rbt'
    instance.template(:blah1).destination.should == '/tmp/blah.rb'
  end
  
  it "should not return a template with an option that does not match." do
    @generator_class.option :framework, :default => :rails
    
    @generator_class.template(:merb, 'blah.rb', :framework => :merb)
    @generator_class.template(:rails, 'blah2.rb', :framework => :rails)
    @generator_class.template(:none, 'blah2.rb')
    
    instance = @generator_class.new('/tmp')

    instance.template(:rails).name.should == :rails
    instance.template(:merb).should be_nil
    instance.template(:none).name.should == :none

    instance.framework = :merb
    instance.template(:rails).should be_nil
    instance.template(:merb).name.should == :merb
    instance.template(:none).name.should == :none

    instance.framework = nil
    instance.template(:rails).should be_nil
    instance.template(:merb).should be_nil
    instance.template(:none).name.should == :none
  end
end

describe Templater::Generator, '#templates' do

  before do
    @generator_class = Class.new(Templater::Generator)
    @generator_class.class_eval do
      def source_root
        '/tmp/source'
      end
    end
  end

  it "should return all templates" do
    @generator_class.template(:blah1, 'blah.rb')
    @generator_class.template(:blah2, 'blah2.rb')
    
    instance = @generator_class.new('/tmp')
    
    instance.templates[0].name.should == :blah1
    instance.templates[1].name.should == :blah2
  end
  
  it "should not return templates with an option that does not match." do
    @generator_class.option :framework, :default => :rails
    
    @generator_class.template(:merb, 'blah.rb', :framework => :merb)
    @generator_class.template(:rails, 'blah2.rb', :framework => :rails)
    @generator_class.template(:none, 'blah2.rb')
    
    instance = @generator_class.new('/tmp')

    instance.templates[0].name.should == :rails
    instance.templates[1].name.should == :none

    instance.framework = :merb
    instance.templates[0].name.should == :merb
    instance.templates[1].name.should == :none

    instance.framework = :rails
    instance.templates[0].name.should == :rails
    instance.templates[1].name.should == :none
    
    instance.framework = nil
    instance.templates[0].name.should == :none
  end
end

describe Templater::Generator, '#generates' do

  before do
    @generator_class = Class.new(Templater::Generator)
    @generator_class.class_eval do
      def source_root
        '/tmp/source'
      end
    end
  end

  it "should return all generates" do
    @generator_class.invoke(:blah1)
    @generator_class.invoke(:blah2)
    
    instance = @generator_class.new('/tmp')
    
    instance.invocations[0].first.should == :blah1
    instance.invocations[1].first.should == :blah2
  end
  
  it "should not return templates with an option that does not match." do
    @generator_class.option :framework, :default => :rails
    
    @generator_class.invoke(:merb, :framework => :merb)
    @generator_class.invoke(:rails, :framework => :rails)
    @generator_class.invoke(:none)
    
    instance = @generator_class.new('/tmp')

    instance.invocations[0].first.should == :rails
    instance.invocations[1].first.should == :none

    instance.framework = :merb
    instance.invocations[0].first.should == :merb
    instance.invocations[1].first.should == :none

    instance.framework = :rails
    instance.invocations[0].first.should == :rails
    instance.invocations[1].first.should == :none
    
    instance.framework = nil
    instance.invocations[0].first.should == :none
  end
end

describe Templater::Generator, '#invoke!' do

  before do
    @generator_class = Class.new(Templater::Generator)
  end

  it "should invoke all templates" do
    template1 = mock('a template')
    template2 = mock('another template')
    
    instance = @generator_class.new('/tmp')
    
    instance.should_receive(:templates).and_return([template1, template2])
    template1.should_receive(:invoke!)
    template2.should_receive(:invoke!)

    instance.invoke!
  end
end


describe Templater::Generator, '#destination_root' do
  it "should be remembered" do
    @generator_class = Class.new(Templater::Generator)
    instance = @generator_class.new('/path/to/destination')
    instance.destination_root.should == '/path/to/destination'
  end
end

describe Templater::Generator, '#source_root' do
  it "should raise an error, complaining that source_root must be overridden" do
    @generator_class = Class.new(Templater::Generator)
    @generator_class.argument(0, :monkey)
    instance = @generator_class.new('/tmp')
    
    lambda { @instance.source_root }.should raise_error
  end
end