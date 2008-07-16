require File.dirname(__FILE__) + '/../spec_helper'

describe Templater::Generator, '.file' do

  before do
    @generator_class = Class.new(Templater::Generator)
  end

  it "should add a file with source and destination" do
    @generator_class.file(:my_template, 'path/to/source.rbt', 'path/to/destination.rb')
    @instance = @generator_class.new('/tmp/destination')
    
    @instance.stub!(:source_root).and_return('/tmp/source')
    
    @instance.file(:my_template).source.should == '/tmp/source/path/to/source.rbt'
    @instance.file(:my_template).destination.should == '/tmp/destination/path/to/destination.rb'
    @instance.file(:my_template).should be_an_instance_of(Templater::File)
  end
  
  it "should add a file with source and infer destination " do
    @generator_class.file(:my_template, 'path/to/file.rb')
    @instance = @generator_class.new('/tmp/destination')
    
    @instance.stub!(:source_root).and_return('/tmp/source')
    
    @instance.file(:my_template).source.should == '/tmp/source/path/to/file.rb'
    @instance.file(:my_template).destination.should == '/tmp/destination/path/to/file.rb'
    @instance.file(:my_template).should be_an_instance_of(Templater::File)
  end
  
  it "should add a file and convert an instruction encoded in the destination, but not one encoded in the source" do
    @generator_class.file(:my_template, 'template/%some_method%.rbt', 'template/%another_method%.rb')
    @instance = @generator_class.new('/tmp/destination')
    
    @instance.stub!(:source_root).and_return('/tmp/source')
    @instance.should_not_receive(:some_method)
    @instance.should_receive(:another_method).at_least(:once).and_return('beast')
    
    @instance.file(:my_template).source.should == '/tmp/source/template/%some_method%.rbt'
    @instance.file(:my_template).destination.should == "/tmp/destination/template/beast.rb"
    @instance.file(:my_template).should be_an_instance_of(Templater::File)
  end
  
  it "should add a file and leave an encoded instruction be if it doesn't exist as a method" do
    @generator_class.file(:my_template, 'template/blah.rbt', 'template/%some_method%.rb')
    @instance = @generator_class.new('/tmp/destination')
    
    @instance.stub!(:source_root).and_return('/tmp/source')
    
    @instance.file(:my_template).destination.should == "/tmp/destination/template/%some_method%.rb"
    @instance.file(:my_template).should be_an_instance_of(Templater::File)
  end
end
