require File.dirname(__FILE__) + '/spec_helper'

describe Templater::Manifold, '#add' do
  
  it "should allow addition of generators and remember them" do
    generator = mock('a generator')
    manifold = class << self; self end
    manifold.extend Templater::Manifold
    manifold.add(:monkey, generator)
    manifold.generator(:monkey).should == generator
    manifold.generators[:monkey].should == generator
  end
  
  it "should add a trippy convenience method" do
    generator = mock('a generator')
    manifold = class << self; self end
    manifold.extend Templater::Manifold
    manifold.add(:monkey, generator)
    manifold.monkey.should == generator
  end
  
end

describe Templater::Manifold, '#remove' do
  
  it "should allow removal of generators" do
    generator = mock('a generator')
    manifold = class << self; self end
    manifold.extend Templater::Manifold
    manifold.add(:monkey, generator)
    manifold.remove(:monkey)
    manifold.generator(:monkey).should be_nil
    manifold.generators[:monkey].should be_nil
  end
  
  it "should remove the accessor method" do
    generator = mock('a generator')
    manifold = class << self; self end
    manifold.extend Templater::Manifold
    
    manifold.add(:monkey, generator)
    manifold.remove(:monkey)
    manifold.should_not respond_to(:monkey)
  end

end

describe Templater::Manifold, '#run_cli' do

  it "should run the command line interface" do
    manifold = class << self; self end
    manifold.extend Templater::Manifold
        
    Templater::CLI::Manifold.should_receive(:run).with('/path/to/destination', manifold, 'gen', '0.3', ['arg', 'blah'])
    
    manifold.run_cli('/path/to/destination', 'gen', '0.3', ['arg', 'blah'])
  end

end

describe Templater::Manifold, '#desc' do

  it "should append text when called with an argument, and return it when called with no argument" do
    manifold = class << self; self end
    manifold.extend Templater::Manifold
    
    manifold.desc "some text"
    manifold.desc.should == "some text"
  end

end