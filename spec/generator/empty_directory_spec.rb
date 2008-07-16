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
