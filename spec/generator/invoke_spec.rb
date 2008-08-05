require File.dirname(__FILE__) + '/../spec_helper'

describe Templater::Generator, '.invoke' do

  before do
    @generator_class = Class.new(Templater::Generator)
    @generator_class.first_argument :test1
    @generator_class.second_argument :test2
    
    @invoked_generator = mock('an invoked generator')
    @invoked_instance = mock('an instance of the invoked generator')
    @invoked_generator.stub!(:new).and_return(@invoked_instance)
    
    @manifold = mock('a manifold')
    @manifold.stub!(:generator).with(:test).and_return(@invoked_generator)
  end

  it "should add nothing if there is no manifold" do
    @generator_class.invoke(:test)
    @instance = @generator_class.new('/tmp', {}, 'test', 'argument')

    @instance.invocations.should be_empty
  end

  describe "with no block" do
    
    before(:each) do
      @generator_class.stub!(:manifold).and_return(@manifold)
    end
    
    it "should return the instantiaded template" do
      @generator_class.invoke(:test)
      @instance = @generator_class.new('/tmp', {}, 'test', 'argument')

      @instance.invocations.first.should == @invoked_instance
    end
    
    it "should ask the manifold for the generator" do
      @generator_class.should_receive(:manifold).at_least(:once).and_return(@manifold)
      @manifold.should_receive(:generator).with(:test).and_return(@invoked_generator)
      @generator_class.invoke(:test)
      @instance = @generator_class.new('/tmp', {}, 'test', 'argument')
      
      @instance.invocations.first.should == @invoked_instance
    end
    
    it "should instantiate the generator with the correct arguments" do
      @invoked_generator.should_receive(:new).with('/tmp', {}, 'test', 'argument').and_return(@invoked_instance)
      @generator_class.invoke(:test)
      @instance = @generator_class.new('/tmp', {}, 'test', 'argument')
      
      @instance.invocations.first.should == @invoked_instance
    end
    
  end
  
  describe "with a block" do
    
    before(:each) do
      @generator_class.stub!(:manifold).and_return(@manifold)
    end
    
    it "should pass the generator class to the block and return the result of it" do    
      @generator_class.invoke(:test) do |generator|
        generator.new(destination_root, options, 'blah', 'monkey', some_method)
      end
      @instance = @generator_class.new('/tmp', {}, 'test', 'argument')
      
      @instance.should_receive(:some_method).and_return('da')
      @invoked_generator.should_receive(:new).with('/tmp', {}, 'blah', 'monkey', 'da').and_return(@invoked_instance)
      
      @instance.invocations.first.should == @invoked_instance
    end
    
    it "should ask the manifold for the generator" do
      @generator_class.should_receive(:manifold).at_least(:once).and_return(@manifold)
      @manifold.should_receive(:generator).with(:test).and_return(@invoked_generator)
      
      @generator_class.invoke(:test) do |generator|
        generator.new(destination_root, options, 'blah', 'monkey')
      end

      @instance = @generator_class.new('/tmp', {}, 'test', 'argument')      
      @instance.invocations.first.should == @invoked_instance
    end
  end
end



describe Templater::Generator, '#invoke!' do

  before do
    @generator_class = Class.new(Templater::Generator)
  end

  it "should invoke all actions" do
    template1 = mock('a template')
    template2 = mock('another template')
    
    instance = @generator_class.new('/tmp')
    
    instance.should_receive(:actions).and_return([template1, template2])
    template1.should_receive(:invoke!)
    template2.should_receive(:invoke!)

    instance.invoke!
  end
end
