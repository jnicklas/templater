require File.dirname(__FILE__) + '/../spec_helper'

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
    @generator_class.send(:attr_accessor, :framework)
    
    @generator_class.template(:merb, 'blah.rb', :framework => :merb)
    @generator_class.template(:rails, 'blah2.rb', :framework => :rails)
    @generator_class.template(:none, 'blah2.rb')
    
    instance = @generator_class.new('/tmp')

    instance.framework = :rails
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
