require File.dirname(__FILE__) + '/../spec_helper'

describe Templater::Generator, '.source_root' do
  it "should raise an error, complaining that source_root must be overridden" do
    @generator_class = Class.new(Templater::Generator)    
    lambda { @generator_class.source_root }.should raise_error(Templater::SourceNotSpecifiedError)
  end
end
