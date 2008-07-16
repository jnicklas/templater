require File.dirname(__FILE__) + '/../spec_helper'

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
