require File.dirname(__FILE__) + '/../spec_helper'

describe Templater::Generator, ".empty_directory" do
  before do
    @generator_class = Class.new(Templater::Generator)
  end

  it "adds directory path to list of directories that should be created" do
    lambda do
      @generator_class.empty_directory :bin, "bin"
    end.should change(@generator_class.empty_directories, :size)    
  end
  
  it "calculates directory path relatively to destination root" do
    @generator_class.empty_directory :bin, "bin/swf"
    
    @instance = @generator_class.new("/tmp/destination")
    @instance.empty_directory(:bin).destination.should == "/tmp/destination/bin/swf"
  end  
end

describe Templater::Generator, '#empty_directories' do

  before do
    @generator_class = Class.new(Templater::Generator)
  end

  it "should return all empty directories" do
    @generator_class.empty_directory(:blah1, 'blah.rb')
    @generator_class.empty_directory(:blah2, 'blah2.rb')
    
    instance = @generator_class.new('/tmp')
    
    instance.empty_directories[0].name.should == :blah1
    instance.empty_directories[1].name.should == :blah2
  end
  
  it "should not return empty directories with an option that does not match." do
    @generator_class.option :framework, :default => :rails
    
    @generator_class.empty_directory(:merb, 'blah.rb', :framework => :merb)
    @generator_class.empty_directory(:rails, 'blah2.rb', :framework => :rails)
    @generator_class.empty_directory(:none, 'blah2.rb')
    
    instance = @generator_class.new('/tmp')

    instance.empty_directories[0].name.should == :rails
    instance.empty_directories[1].name.should == :none

    instance.framework = :merb
    instance.empty_directories[0].name.should == :merb
    instance.empty_directories[1].name.should == :none

    instance.framework = :rails
    instance.empty_directories[0].name.should == :rails
    instance.empty_directories[1].name.should == :none
    
    instance.framework = nil
    instance.empty_directories[0].name.should == :none
  end
end

describe Templater::Generator, '#empty_directory' do

  before do
    @generator_class = Class.new(Templater::Generator)
  end

  it "should find a empty_directory by name" do
    @generator_class.empty_directory(:blah1, 'blah.rb')
    @generator_class.empty_directory(:blah2, 'blah2.rb')
    
    instance = @generator_class.new('/tmp')
    
    instance.empty_directory(:blah1).name.should == :blah1
    instance.empty_directory(:blah1).destination.should == '/tmp/blah.rb'
  end
  
  it "should not return a empty_directory with an option that does not match." do
    @generator_class.send(:attr_accessor, :framework)
    
    @generator_class.empty_directory(:merb, 'blah.rb', :framework => :merb)
    @generator_class.empty_directory(:rails, 'blah2.rb', :framework => :rails)
    @generator_class.empty_directory(:none, 'blah2.rb')
    
    instance = @generator_class.new('/tmp')

    instance.framework = :rails
    instance.empty_directory(:rails).name.should == :rails
    instance.empty_directory(:merb).should be_nil
    instance.empty_directory(:none).name.should == :none

    instance.framework = :merb
    instance.empty_directory(:rails).should be_nil
    instance.empty_directory(:merb).name.should == :merb
    instance.empty_directory(:none).name.should == :none

    instance.framework = nil
    instance.empty_directory(:rails).should be_nil
    instance.empty_directory(:merb).should be_nil
    instance.empty_directory(:none).name.should == :none
  end
end