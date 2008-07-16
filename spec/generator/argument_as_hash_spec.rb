require File.dirname(__FILE__) + '/../spec_helper'

describe Templater::Generator, '.argument as hash' do

  before do
    @generator_class = Class.new(Templater::Generator)
    @generator_class.argument(0, :monkey)
    @generator_class.argument(1, :llama, :as => :hash)
  end
  
  it "should allow assignment of hashes" do
    instance = @generator_class.new('/tmp', {}, 'a monkey', { :hash => 'blah' })
    
    instance.monkey.should == 'a monkey'
    instance.llama[:hash].should == 'blah'
    
    instance.llama = { :me_s_a => :hash }
    instance.llama[:me_s_a].should == :hash
  end
  
  it "should convert a key/value pair to a hash" do
    instance = @generator_class.new('/tmp', {}, 'a monkey', 'test:unit')
    instance.llama['test'].should == 'unit'
  end
  
  it "should consume the remaining arguments and convert them to a hash if they are key/value pairs" do
    instance = @generator_class.new('/tmp', {}, 'a monkey', 'test:unit', 'john:silver', 'river:road')
    instance.llama['test'].should == 'unit'
    instance.llama['john'].should == 'silver'
    instance.llama['river'].should == 'road'
  end
  
  it "should raise an error if one of the remaining arguments is not a key/value pair" do
    lambda { @generator_class.new('/tmp', {}, 'a monkey', 'a:llama', 'duck:llama', 'not_a_pair', 'pair:blah') }.should raise_error(Templater::MalformattedArgumentError)
  end
  
  it "should raise error if the argument is neither a hash nor a key/value pair" do
    lambda { @generator_class.new('/tmp', {}, 'a monkey', 23) }.should raise_error(Templater::MalformattedArgumentError)
    instance = @generator_class.new('/tmp')
    lambda { instance.llama = :not_a_hash }.should raise_error(Templater::MalformattedArgumentError)
  end

end
