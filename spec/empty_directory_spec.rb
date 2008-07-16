require File.dirname(__FILE__) + '/spec_helper'

describe Templater::EmptyDirectory, '.new' do
  it "sets name and destination" do
    Templater::EmptyDirectory.new(:monkey, '/path/to/destination').
      name.should == :monkey
  end

  it 'sets destination' do
    Templater::EmptyDirectory.new(:monkey, '/path/to/destination').
      destination.should == '/path/to/destination'    
  end
end




describe Templater::EmptyDirectory, '#relative_destination' do
  it "returns destination relative to the pwd" do
    Dir.stub!(:pwd).and_return('/path/to')
    file = Templater::EmptyDirectory.new(:monkey, '/path/to/destination/with/some/more/subdirs')
    file.relative_destination.should == 'destination/with/some/more/subdirs'
  end
end




describe Templater::EmptyDirectory, '#render' do
  it 'does nothing for empty directories?'
end




describe Templater::EmptyDirectory, '#exists?' do
  
  it "should exist if the destination file exists" do  
    file = Templater::EmptyDirectory.new(:monkey, result_path('erb.rbs'))
    file.should be_exists
  end
  
  it "should not exist if the destination file does not exist" do  
    file = Templater::EmptyDirectory.new(:monkey, result_path('some_weird_file.rbs'))
    file.should_not be_exists
  end
end



describe Templater::EmptyDirectory, '#identical' do
  it "should not be identical if the destination file doesn't exist" do  
    file = Templater::EmptyDirectory.new(:monkey, result_path('some_weird/path/that_does/not_exist'))
    file.should_not be_identical
  end
  
  it "should not be identical if the destination file is not identical to the source file" do
    file = Templater::EmptyDirectory.new(:monkey, result_path('simple_erb.rbs'))
    file.should be_exists
    file.should be_identical
  end
  
  it "should be identical if the destination file is identical to the source file" do
    file= Templater::EmptyDirectory.new(:monkey, result_path('file.rbs'))
    file.should be_exists
    file.should be_identical
  end
end



describe Templater::EmptyDirectory, '#invoke!' do
  it "should copy the source file to the destination" do
    file = Templater::EmptyDirectory.new(:monkey, result_path('path/to/subdir/test2.rbs'))
    
    file.invoke!
    
    File.exists?(result_path('path/to/subdir/test2.rbs')).should be_true
    
    # cleanup
    FileUtils.rm_rf(result_path('path'))
  end
end



describe Templater::EmptyDirectory, '#revoke!' do
  it "removes the destination directory" do
    file = Templater::EmptyDirectory.new(:monkey, result_path('path/to/empty/subdir/'))
    
    file.invoke!
    File.exists?(result_path('path/to/empty/subdir/')).should be_true
    
    file.revoke!
    File.exists?(result_path('path/to/empty/subdir/')).should be_false
  end
end
