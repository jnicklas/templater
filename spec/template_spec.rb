require File.dirname(__FILE__) + '/spec_helper'

describe Templater::Template, '.new' do
  it "should set name, source and destination" do
    template = Templater::Template.new('some_context', :monkey, '/path/to/source', '/path/to/destination')
    template.context.should == 'some_context'
    template.name.should == :monkey
    template.source.should == '/path/to/source'
    template.destination.should == '/path/to/destination'
  end
end


describe Templater::Template, '#render' do
  before do
    @context = class << self; self end
  end
  
  it "should render a simple template" do  
    template = Templater::Template.new(@context, :monkey, template_path('simple.rbt'), '/path/to/destination')
    template.render.should == "Hello World"
  end
  
  it "should render some basic erb" do  
    template = Templater::Template.new(@context, :monkey, template_path('simple_erb.rbt'), '/path/to/destination')
    template.render.should == "test2test"
  end
  
  it "should render some erb fetching stuff from the context" do
    @context.should_receive(:funkydoodle).and_return('_doodle_')
    template = Templater::Template.new(@context, :monkey, template_path('erb.rbt'), '/path/to/destination')
    template.render.should == "test_doodle_blah"
  end
end

describe Templater::Template, '#exists?' do
  
  it "should exist if the destination file exists" do  
    template = Templater::Template.new(@context, :monkey, template_path('simple.rbt'), result_path('erb.rbs'))
    template.should be_exists
  end
  
  it "should not exist if the destination file does not exist" do  
    template = Templater::Template.new(@context, :monkey, template_path('simple.rbt'), result_path('some_weird_file.rbs'))
    template.should_not be_exists
  end
  
end

describe Templater::Template, '#identical' do
  before do
    @context = class << self; self end
  end
  
  it "should not be identical if the destination file doesn't exist" do  
    template = Templater::Template.new(@context, :monkey, template_path('simple_erb.rbt'), result_path('some_weird_file.rbs'))
    template.should_not be_identical
  end
  
  it "should not be identical if the rendered content does not match the content of the file" do  
    template = Templater::Template.new(@context, :monkey, template_path('simple_erb.rbt'), result_path('random.rbs'))
    template.should be_exists
    template.should_not be_identical
  end
  
  it "should be identical if the rendered content matches the content of the file" do  
    template = Templater::Template.new(@context, :monkey, template_path('simple_erb.rbt'), result_path('simple_erb.rbs'))
    template.should be_exists
    template.should be_identical
  end
end

describe Templater::Template, '#invoke!' do
  before do
    @context = class << self; self end
  end
  
  it "should render the template and copy it to the destination" do  
    template = Templater::Template.new(@context, :monkey, template_path('simple_erb.rbt'), result_path('test.rbs'))
    
    template.invoke!
    
    File.exists?(result_path('test.rbs')).should be_true
    File.read(result_path('test.rbs')).should == "test2test"
    
    FileUtils.rm(result_path('test.rbs'))
  end
  
  it "should render the template and copy it to the destination, creating any required subdirectories" do  
    template = Templater::Template.new(@context, :monkey, template_path('simple_erb.rbt'), result_path('path/to/subdir/test.rbs'))
    
    template.invoke!
    
    File.exists?(result_path('path/to/subdir/test.rbs')).should be_true
    File.read(result_path('path/to/subdir/test.rbs')).should == "test2test"
    
    # cleanup
    FileUtils.rm(result_path('path/to/subdir/test.rbs'))
    FileUtils.rm_rf(result_path('path'))
  end
end
