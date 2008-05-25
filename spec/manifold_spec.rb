require File.dirname(__FILE__) + '/spec_helper'

describe Templater::Manifold do
  
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
  
  it "should run the command line interface" do
    generator = mock('a generator')
    manifold = class << self; self end
    manifold.extend Templater::Manifold
        
    Templater::CLI.should_receive(:run).with(manifold, ['arg', 'blah'])
    
    manifold.run_cli(['arg', 'blah'])
  end

  
end