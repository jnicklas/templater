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

describe Templater::Template, '#relative_destination' do
  it "should get the destination relative to the pwd" do
    Dir.stub!(:pwd).and_return('/path/to')
    template = Templater::Template.new('some_context', :monkey, '/path/to/source', '/path/to/destination/with/some/more/subdirs')
    template.relative_destination.should == 'destination/with/some/more/subdirs'
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
  
  it "should render some erb and convert erb literals" do  
    template = Templater::Template.new(@context, :monkey, template_path('literals_erb.rbt'), '/path/to/destination')
    template.render.should == "test2test<%= 1+1 %>blah"
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
    FileUtils.rm_rf(result_path('path'))
  end
  
  it "should simply copy the template to the destination if render is false" do
    template = Templater::Template.new(@context, :monkey, template_path('simple_erb.rbt'), result_path('path/to/subdir/test2.rbs'), false)
    
    template.invoke!
    
    File.exists?(result_path('path/to/subdir/test2.rbs')).should be_true
    FileUtils.identical?(template_path('simple_erb.rbt'), result_path('path/to/subdir/test2.rbs')).should be_true
    
    # cleanup
    FileUtils.rm_rf(result_path('path'))
  end
end


describe Templater::Template, '#revoke!' do
  
  it "should remove the destination file" do
    template = Templater::Template.new(@context, :monkey, template_path('simple_erb.rbt'), result_path('test.rbs'))
    
    template.invoke!
    
    File.exists?(result_path('test.rbs')).should be_true
    File.read(result_path('test.rbs')).should == "test2test"
    
    template.revoke!
    
    File.exists?(result_path('test.rbs')).should be_false
  end
  
end