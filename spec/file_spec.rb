require File.dirname(__FILE__) + '/spec_helper'

describe Templater::File, '.new' do
  it "should set name, source and destination" do
    file = Templater::File.new(:monkey, '/path/to/source', '/path/to/destination')
    file.name.should == :monkey
    file.source.should == '/path/to/source'
    file.destination.should == '/path/to/destination'
  end
end

describe Templater::File, '#relative_destination' do
  it "should get the destination relative to the pwd" do
    Dir.stub!(:pwd).and_return('/path/to')
    file = Templater::File.new(:monkey, '/path/to/source', '/path/to/destination/with/some/more/subdirs')
    file.relative_destination.should == 'destination/with/some/more/subdirs'
  end
end

describe Templater::File, '#render' do
  it "should output the file" do  
    file = Templater::File.new(:monkey, template_path('simple_erb.rbt'), '/path/to/destination')
    file.render.should == "test<%= 1+1 %>test"
  end
end

describe Templater::File, '#exists?' do
  
  it "should exist if the destination file exists" do  
    file = Templater::File.new(:monkey, template_path('simple.rbt'), result_path('erb.rbs'))
    file.should be_exists
  end
  
  it "should not exist if the destination file does not exist" do  
    file = Templater::File.new(:monkey, template_path('simple.rbt'), result_path('some_weird_file.rbs'))
    file.should_not be_exists
  end
  
end

describe Templater::File, '#identical' do
  
  it "should not be identical if the destination file doesn't exist" do  
    file = Templater::File.new(:monkey, template_path('simple_erb.rbt'), result_path('some_weird_file.rbs'))
    file.should_not be_identical
  end
  
  it "should not be identical if the destination file is not identical to the source file" do
    file = Templater::File.new(:monkey, template_path('simple_erb.rbt'), result_path('simple_erb.rbs'))
    file.should be_exists
    file.should_not be_identical
  end
  
  it "should be identical if the destination file is identical to the source file" do
    file= Templater::File.new(:monkey, template_path('simple_erb.rbt'), result_path('file.rbs'))
    file.should be_exists
    file.should be_identical
  end
end

describe Templater::File, '#invoke!' do
  
  it "should copy the source file to the destination" do
    file = Templater::File.new(:monkey, template_path('simple_erb.rbt'), result_path('path/to/subdir/test2.rbs'))
    
    file.invoke!
    
    File.exists?(result_path('path/to/subdir/test2.rbs')).should be_true
    FileUtils.identical?(template_path('simple_erb.rbt'), result_path('path/to/subdir/test2.rbs')).should be_true
    
    # cleanup
    FileUtils.rm_rf(result_path('path'))
  end
end

describe Templater::File, '#revoke!' do
  
  it "should remove the destination file" do
    file = Templater::File.new(:monkey, template_path('simple_erb.rbt'), result_path('path/to/subdir/test2.rbs'))
    
    file.invoke!
    
    File.exists?(result_path('path/to/subdir/test2.rbs')).should be_true
    FileUtils.identical?(template_path('simple_erb.rbt'), result_path('path/to/subdir/test2.rbs')).should be_true
    
    file.revoke!
    
    File.exists?(result_path('path/to/subdir/test2.rbs')).should be_false
  end
  
end
