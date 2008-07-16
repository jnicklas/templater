require File.dirname(__FILE__) + '/../spec_helper'

describe Templater::Generator, '#actions' do

  before do
    @generator_class = Class.new(Templater::Generator)
    @generator_class.class_eval do
      def source_root
        '/tmp/source'
      end
    end
    
    @generator1 = mock('a generator')
    @instance1 = mock('an instance of the generator')
    @generator1.stub!(:new).and_return(@instance1)
    @generator2 = mock('another generator')
    @instance2 = mock('an instance of another generator')
    @generator2.stub!(:new).and_return(@instance2)
    
    @manifold = mock('a manifold')
    @manifold.stub!(:generator).with(:one).and_return(@generator1)
    @manifold.stub!(:generator).with(:two).and_return(@generator2)
    @manifold.stub!(:generator).with(:three).and_return(@generator3)
    
    @generator_class.stub!(:manifold).and_return(@manifold)
  end

  it "should return all templates and files" do    
    instance = @generator_class.new('/tmp')
    instance.should_receive(:templates).at_least(:once).and_return(['template1', 'template2'])
    instance.should_receive(:files).at_least(:once).and_return(['file1', 'file2'])
    
    instance.actions.should include('template1')
    instance.actions.should include('template2')
    instance.actions.should include('file1')
    instance.actions.should include('file2')
  end
  
  it "should return all templates and files recursively for all invocations" do
    instance = @generator_class.new('/tmp')
    instance.should_receive(:templates).at_least(:once).and_return(['template1', 'template2'])
    instance.should_receive(:files).at_least(:once).and_return(['file1', 'file2'])
    instance.should_receive(:empty_directories).at_least(:once).and_return(['public', 'bin'])
    instance.should_receive(:invocations).at_least(:once).and_return([@instance1, @instance2])
    
    @instance1.should_receive(:actions).at_least(:once).and_return(['subtemplate1', 'subfile1'])
    @instance2.should_receive(:actions).at_least(:once).and_return(['subtemplate2', 'subfile2'])
    
    instance.actions.should include('template1')
    instance.actions.should include('template2')
    instance.actions.should include('subtemplate1')
    instance.actions.should include('subtemplate2')
    instance.actions.should include('file1')
    instance.actions.should include('file2')
    instance.actions.should include('subfile1')
    instance.actions.should include('subfile2')

    instance.actions.should include('public')
    instance.actions.should include('bin')    
  end
  
end
