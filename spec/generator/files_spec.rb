require File.dirname(__FILE__) + '/../spec_helper'

describe Templater::Generator, '#files' do

  before do
    @generator_class = Class.new(Templater::Generator)
    @generator_class.class_eval do
      def source_root
        '/tmp/source'
      end
    end
  end

  it "should return all files" do
    @generator_class.file(:blah1, 'blah.rb')
    @generator_class.file(:blah2, 'blah2.rb')
    
    instance = @generator_class.new('/tmp')
    
    instance.files[0].name.should == :blah1
    instance.files[1].name.should == :blah2
  end
  
  it "should not return files with an option that does not match." do
    @generator_class.option :framework, :default => :rails
    
    @generator_class.file(:merb, 'blah.rb', :framework => :merb)
    @generator_class.file(:rails, 'blah2.rb', :framework => :rails)
    @generator_class.file(:none, 'blah2.rb')
    
    instance = @generator_class.new('/tmp')

    instance.files[0].name.should == :rails
    instance.files[1].name.should == :none

    instance.framework = :merb
    instance.files[0].name.should == :merb
    instance.files[1].name.should == :none

    instance.framework = :rails
    instance.files[0].name.should == :rails
    instance.files[1].name.should == :none
    
    instance.framework = nil
    instance.files[0].name.should == :none
  end
end
