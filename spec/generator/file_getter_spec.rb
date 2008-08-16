require File.dirname(__FILE__) + '/../spec_helper'

describe Templater::Generator, '#file' do

  before do
    @generator_class = Class.new(Templater::Generator)
    @generator_class.class_eval do
      def source_root
        '/tmp/source'
      end
    end
  end

  it "should find a file by name" do
    @generator_class.file(:blah1, 'blah.rb')
    @generator_class.file(:blah2, 'blah2.rb')
    
    instance = @generator_class.new('/tmp')
    
    instance.file(:blah1).name.should == :blah1
    instance.file(:blah1).source.should == '/tmp/source/blah.rb'
    instance.file(:blah1).destination.should == '/tmp/blah.rb'
  end
  
  it "should not return a file with an option that does not match." do
    @generator_class.send(:attr_accessor, :framework)
    
    @generator_class.file(:merb, 'blah.rb', :framework => :merb)
    @generator_class.file(:rails, 'blah2.rb', :framework => :rails)
    @generator_class.file(:none, 'blah2.rb')
    
    instance = @generator_class.new('/tmp')

    instance.framework = :rails
    instance.file(:rails).name.should == :rails
    instance.file(:merb).should be_nil
    instance.file(:none).name.should == :none

    instance.framework = :merb
    instance.file(:rails).should be_nil
    instance.file(:merb).name.should == :merb
    instance.file(:none).name.should == :none

    instance.framework = nil
    instance.file(:rails).should be_nil
    instance.file(:merb).should be_nil
    instance.file(:none).name.should == :none
  end
end
