require File.dirname(__FILE__) + '/../spec_helper'

describe Templater::Generator, '.template' do

  before do
    @generator_class = Class.new(Templater::Generator)
  end

  it "should add a template with source and destination" do
    @generator_class.template(:my_template, 'path/to/source.rbt', 'path/to/destination.rb')
    @instance = @generator_class.new('/tmp/destination')
    
    @instance.stub!(:source_root).and_return('/tmp/source')
    
    @instance.template(:my_template).source.should == '/tmp/source/path/to/source.rbt'
    @instance.template(:my_template).destination.should == '/tmp/destination/path/to/destination.rb'
    @instance.template(:my_template).should be_an_instance_of(Templater::Actions::Template)
  end
  
  it "should add a template with absolute source and destination" do
    @generator_class.template(:my_template, '/path/to/source.rbt', '/path/to/destination.rb')
    @instance = @generator_class.new('/tmp/destination')
    
    @instance.stub!(:source_root).and_return('/tmp/source')
    
    @instance.template(:my_template).source.should == '/path/to/source.rbt'
    @instance.template(:my_template).destination.should == '/path/to/destination.rb'
    @instance.template(:my_template).should be_an_instance_of(Templater::Actions::Template)
  end
  
  it "should add a template with destination and infer the source" do
    @generator_class.template(:my_template, 'path/to/destination.rb')
    @instance = @generator_class.new('/tmp/destination')
    
    @instance.stub!(:source_root).and_return('/tmp/source')
    
    @instance.template(:my_template).source.should == '/tmp/source/path/to/destination.rbt'
    @instance.template(:my_template).destination.should == '/tmp/destination/path/to/destination.rb'
    @instance.template(:my_template).should be_an_instance_of(Templater::Actions::Template)
  end
  
  it "should add a template with a block" do
    @generator_class.template(:my_template) do
      source 'blah.rbt'
      destination "gurr#{Process.pid.to_s}.rb"
    end
    @instance = @generator_class.new('/tmp/destination')
    
    @instance.stub!(:source_root).and_return('/tmp/source')
    
    @instance.template(:my_template).source.should == '/tmp/source/blah.rbt'
    @instance.template(:my_template).destination.should == "/tmp/destination/gurr#{Process.pid.to_s}.rb"
    @instance.template(:my_template).should be_an_instance_of(Templater::Actions::Template)
  end
  
  it "should add a template and convert an with an instruction encoded in the destination, but not one encoded in the source" do
    @generator_class.template(:my_template, 'template/%some_method%.rbt', 'template/%another_method%.rb')
    @instance = @generator_class.new('/tmp/destination')
    
    @instance.stub!(:source_root).and_return('/tmp/source')
    @instance.should_not_receive(:some_method)
    @instance.should_receive(:another_method).at_least(:once).and_return('beast')
    
    @instance.template(:my_template).source.should == '/tmp/source/template/%some_method%.rbt'
    @instance.template(:my_template).destination.should == "/tmp/destination/template/beast.rb"
    @instance.template(:my_template).should be_an_instance_of(Templater::Actions::Template)
  end
  
  it "should add a template and leave an encoded instruction be if it doesn't exist as a method" do
    @generator_class.template(:my_template, 'template/blah.rbt', 'template/%some_method%.rb')
    @instance = @generator_class.new('/tmp/destination')
    
    @instance.stub!(:source_root).and_return('/tmp/source')
    
    @instance.template(:my_template).destination.should == "/tmp/destination/template/%some_method%.rb"
    @instance.template(:my_template).should be_an_instance_of(Templater::Actions::Template)
  end
  
end
