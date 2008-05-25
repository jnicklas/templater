require File.dirname(__FILE__) + '/spec_helper'

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
    
    instance = @generator_class.new('/tmp', 'i am a monkey')
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
    
    instance = @generator_class.new('/tmp', 'a monkey', 'a llama', 'a herd')
    instance.monkey.should == 'a monkey'
    instance.llama.should == 'a llama'
    instance.herd.should == 'a herd'
  end
  
  it "should allow some syntactic sugar declaration" do
    @generator_class.first_argument(:monkey)
    @generator_class.second_argument(:llama)
    @generator_class.third_argument(:herd)
    @generator_class.fourth_argument(:elephant)
    
    instance = @generator_class.new('/tmp', 'a monkey', 'a llama', 'a herd', 'an elephant')
    instance.monkey.should == 'a monkey'
    instance.llama.should == 'a llama'
    instance.herd.should == 'a herd'
    instance.elephant.should == 'an elephant'
  end
  
  it "should whine when there are too many arguments" do
    @generator_class.argument(0, :monkey)
    @generator_class.argument(1, :llama)
    
    lambda { @generator_class.new('/tmp', 'a monkey', 'a llama', 'a herd') }.should raise_error(Templater::TooManyArgumentsError)
  end
  
  it "should allow assignment of hashes to arguments that should be hashes ;)" do
    @generator_class.argument(0, :monkey)
    @generator_class.argument(1, :llama, :as => :hash)
    
    instance = @generator_class.new('/tmp', 'a monkey', { :hash => 'blah' })
    
    instance.monkey.should == 'a monkey'
    instance.llama[:hash].should == 'blah'
    
    instance.llama = { :me_s_a => :hash }
    instance.llama[:me_s_a].should == :hash
  end
  
  it "should raise an error when an argument that should be a hash, is in fact not a hash" do
    @generator_class.argument(0, :monkey)
    @generator_class.argument(1, :llama, :as => :hash)
    
    lambda { @generator_class.new('/tmp', 'a monkey', 'a llama') }.should raise_error(Templater::MalformattedArgumentError)
    instance = @generator_class.new('/tmp')
    lambda { instance.llama = :not_a_hash }.should raise_error(Templater::MalformattedArgumentError)
  end
  
  it "should assign arguments if an argument is required and that requirement is fullfilled" do
    @generator_class.argument(0, :monkey, :required => true)
    @generator_class.argument(1, :elephant, :required => true)
    @generator_class.argument(2, :llama)
    
    instance = @generator_class.new('/tmp', 'enough', 'arguments')
    instance.monkey.should == "enough"
    instance.elephant.should == "arguments"
    instance.llama.should be_nil
  end
  
  it "should raise an error when a required argument is not passed" do
    @generator_class.argument(0, :monkey, :required => true)
    @generator_class.argument(1, :elephant, :required => true)
    @generator_class.argument(2, :llama)
    
    lambda { @generator_class.new('/tmp', 'too few argument') }.should raise_error(Templater::TooFewArgumentsError)    
  end
  
  it "should an error if nil is assigned to a require argument" do
    @generator_class.argument(0, :monkey, :required => true)
    
    instance = @generator_class.new('/tmp', 'test')
    
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
    
    instance = @generator_class.new('/tmp', 'blah', 'urgh')
    instance.monkey.should == 'blah'
    instance.elephant.should == 'urgh'
    
    instance.monkey = :harr
    instance.monkey.should == :harr
  end
  
  it "should raise an error with the throw message, when a block is appended to an argument and throws :invalid" do
    @generator_class.argument(0, :monkey) do
      throw :invalid, 'this is not a valid monkey, bad monkey!'
    end
    
    lambda { @generator_class.new('/tmp', 'blah') }.should raise_error(Templater::ArgumentError, 'this is not a valid monkey, bad monkey!')
    
    instance = @generator_class.new('/tmp')
    
    lambda { instance.monkey = :anything }.should raise_error(Templater::ArgumentError, 'this is not a valid monkey, bad monkey!')
  end

end

describe Templater::Generator, '.template' do

  before do
    @generator_class = Class.new(Templater::Generator)
  end

  it "should add a template proxy" do
    Templater::TemplateProxy.should_receive(:new).with(:my_template) # TODO: Figure out how to set an expectation for the passed block
    @generator_class.template(:my_template) {}
  end
  
  it "should convert template proxies to templates on initialization" do
    template_proxy = mock('a template proxy')

    Templater::TemplateProxy.should_receive(:new).with(:my_template).and_return(template_proxy)
    @generator_class.template(:my_template) {}
    
    template_proxy.should_receive(:to_template)
    @generator_class.new('/tmp')
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
end

describe Templater::Generator, '#template' do

  before do
    @generator_class = Class.new(Templater::Generator)
  end

  it "should get a template by name" do
    template_proxy = mock('a template proxy')
    template = mock('a template')
    template.stub!(:name).and_return(:my_template)

    Templater::TemplateProxy.should_receive(:new).with(:my_template).and_return(template_proxy)
    @generator_class.template(template.name) {}
    
    template_proxy.should_receive(:to_template).and_return(template)
    instance = @generator_class.new('/tmp')
    
    instance.template(:my_template).should == template
  end
end

describe Templater::Generator, '#templates' do

  before do
    @generator_class = Class.new(Templater::Generator)
  end

  it "should return all templates" do
    template_proxy = mock('a template proxy')
    template = mock('a template')
    template.stub!(:name).and_return(:my_template)
    template_proxy2 = mock('a template proxy')
    template2 = mock('a template')
    template2.stub!(:name).and_return(:another_template)

    Templater::TemplateProxy.should_receive(:new).with(:my_template).and_return(template_proxy)
    Templater::TemplateProxy.should_receive(:new).with(:another_template).and_return(template_proxy2)
    @generator_class.template(template.name) {}
    @generator_class.template(template2.name) {}
    
    template_proxy.should_receive(:to_template).and_return(template)
    template_proxy2.should_receive(:to_template).and_return(template2)
    instance = @generator_class.new('/tmp')
    
    instance.templates.should == [template, template2]
  end
  
  it "should not return templates with an option that does not match."
end

describe Templater::Generator, '#invoke!' do

  before do
    @generator_class = Class.new(Templater::Generator)
  end

  it "should invoke all templates" do
    # boring mocking setup
    template_proxy = mock('a template proxy')
    template = mock('a template')
    template.stub!(:name).and_return(:my_template)
    template_proxy2 = mock('a template proxy')
    template2 = mock('a template')
    template2.stub!(:name).and_return(:another_template)

    Templater::TemplateProxy.should_receive(:new).with(:my_template).and_return(template_proxy)
    Templater::TemplateProxy.should_receive(:new).with(:another_template).and_return(template_proxy2)
    @generator_class.template(template.name) {}
    @generator_class.template(template2.name) {}
    
    template_proxy.should_receive(:to_template).and_return(template)
    template_proxy2.should_receive(:to_template).and_return(template2)
    instance = @generator_class.new('/tmp')
    
    # the meaty stuff here
    template.should_receive(:invoke!)
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