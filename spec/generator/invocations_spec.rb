require File.dirname(__FILE__) + '/../spec_helper'

describe Templater::Generator, '#invocations' do

  before do
    @generator_class = Class.new(Templater::Generator)
    @generator_class.class_eval do
      def source_root
        '/tmp/source'
      end
    end
    
    @generator1 = mock('a generator for merb')
    @instance1 = mock('an instance of the generator for merb')
    @generator1.stub!(:new).and_return(@instance1)
    @generator2 = mock('a generator for rails')
    @instance2 = mock('an instance of the generator for rails')
    @generator2.stub!(:new).and_return(@instance2)
    @generator3 = mock('a generator for both')
    @instance3 = mock('an instance of the generator for both')
    @generator3.stub!(:new).and_return(@instance3)
    
    @manifold = mock('a manifold')
    @manifold.stub!(:generator).with(:merb).and_return(@generator1)
    @manifold.stub!(:generator).with(:rails).and_return(@generator2)
    @manifold.stub!(:generator).with(:both).and_return(@generator3)
    
    @generator_class.stub!(:manifold).and_return(@manifold)
  end

  it "should return all invocations" do
    @generator_class.invoke(:merb)
    @generator_class.invoke(:rails)
    
    instance = @generator_class.new('/tmp')
    
    instance.invocations[0].should == @instance1
    instance.invocations[1].should == @instance2
  end
  
  it "should not return templates with an option that does not match." do
    @generator_class.option :framework, :default => :rails
    
    @generator_class.invoke(:merb, :framework => :merb)
    @generator_class.invoke(:rails, :framework => :rails)
    @generator_class.invoke(:both)
    
    instance = @generator_class.new('/tmp')

    instance.invocations[0].should == @instance2
    instance.invocations[1].should == @instance3
                                      
    instance.framework = :merb        
    instance.invocations[0].should == @instance1
    instance.invocations[1].should == @instance3

    instance.framework = :rails       
    instance.invocations[0].should == @instance2
    instance.invocations[1].should == @instance3

    instance.framework = nil          
    instance.invocations[0].should == @instance3
  end
end
