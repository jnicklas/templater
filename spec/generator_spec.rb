require File.dirname(__FILE__) + '/spec_helper'

describe Templater::Generator, '#desc' do

  it "should append text when called with an argument, and return it when called with no argument" do
    @generator_class = Class.new(Templater::Generator)
    
    @generator_class.desc "some text"
    @generator_class.desc.should == "some text"
  end

end

describe Templater::Generator, '.argument' do

  before do
    @generator_class = Class.new(Templater::Generator)
  end
  
  it "should create accessors" do
    @generator_class.argument(0, :monkey)
    
    instance = @generator_class.new('/tmp')
    instance.monkey = 'a test'
    instance.monkey.should == 'a test'
  end
  
  it "should pass an initial value to the argument" do
    @generator_class.argument(0, :monkey)
    
    instance = @generator_class.new('/tmp', {}, 'i am a monkey')
    instance.monkey.should == 'i am a monkey'
  end
  
  it "should create multiple accessors" do
    @generator_class.argument(0, :monkey)
    @generator_class.argument(1, :llama)
    @generator_class.argument(2, :herd)
    
    instance = @generator_class.new('/tmp')
    instance.monkey = 'a monkey'
    instance.monkey.should == 'a monkey'
    instance.llama = 'a llama'
    instance.llama.should == 'a llama'
    instance.herd = 'a herd'
    instance.herd.should == 'a herd'
  end
  
  it "should pass an initial value to multiple accessors" do
    @generator_class.argument(0, :monkey)
    @generator_class.argument(1, :llama)
    @generator_class.argument(2, :herd)
    
    instance = @generator_class.new('/tmp', {}, 'a monkey', 'a llama', 'a herd')
    instance.monkey.should == 'a monkey'
    instance.llama.should == 'a llama'
    instance.herd.should == 'a herd'
  end
  
  it "should set a default value for an argument" do
    @generator_class.argument(0, :monkey, :default => 'a revision')
    
    instance = @generator_class.new('/tmp')
    instance.monkey.should == 'a revision'
  end
  
  it "should allow some syntactic sugar declaration" do
    @generator_class.first_argument(:monkey)
    @generator_class.second_argument(:llama)
    @generator_class.third_argument(:herd)
    @generator_class.fourth_argument(:elephant)
    
    instance = @generator_class.new('/tmp', {}, 'a monkey', 'a llama', 'a herd', 'an elephant')
    instance.monkey.should == 'a monkey'
    instance.llama.should == 'a llama'
    instance.herd.should == 'a herd'
    instance.elephant.should == 'an elephant'
  end
  
  it "should whine when there are too many arguments" do
    @generator_class.argument(0, :monkey)
    @generator_class.argument(1, :llama)
    
    lambda { @generator_class.new('/tmp', {}, 'a monkey', 'a llama', 'a herd') }.should raise_error(Templater::TooManyArgumentsError)
  end
  
  it "should assign arguments if an argument is required and that requirement is fullfilled" do
    @generator_class.argument(0, :monkey, :required => true)
    @generator_class.argument(1, :elephant, :required => true)
    @generator_class.argument(2, :llama)
    
    instance = @generator_class.new('/tmp', {}, 'enough', 'arguments')
    instance.monkey.should == "enough"
    instance.elephant.should == "arguments"
    instance.llama.should be_nil
  end
  
  it "should raise an error when a required argument is not passed" do
    @generator_class.argument(0, :monkey, :required => true)
    @generator_class.argument(1, :elephant, :required => true)
    @generator_class.argument(2, :llama)
    
    lambda { @generator_class.new('/tmp', {}, 'too few arguments') }.should raise_error(Templater::TooFewArgumentsError)    
  end
  
  it "should raise an error if nil is assigned to a require argument" do
    @generator_class.argument(0, :monkey, :required => true)
    
    instance = @generator_class.new('/tmp', {}, 'test')
    
    lambda { instance.monkey = nil }.should raise_error(Templater::TooFewArgumentsError)    
  end
  
  it "should assign an argument when a block appended to an argument does not throw :invalid" do
    @generator_class.argument(0, :monkey) do
      1 + 1
    end
    @generator_class.argument(1, :elephant) do
      false
    end
    @generator_class.argument(2, :llama)
    
    instance = @generator_class.new('/tmp', {}, 'blah', 'urgh')
    instance.monkey.should == 'blah'
    instance.elephant.should == 'urgh'
    
    instance.monkey = :harr
    instance.monkey.should == :harr
  end
  
  it "should raise an error with the throw message, when a block is appended to an argument and throws :invalid" do
    @generator_class.argument(0, :monkey) do
      throw :invalid, 'this is not a valid monkey, bad monkey!'
    end
    
    lambda { @generator_class.new('/tmp', {}, 'blah') }.should raise_error(Templater::ArgumentError, 'this is not a valid monkey, bad monkey!')
    
    instance = @generator_class.new('/tmp')
    
    lambda { instance.monkey = :anything }.should raise_error(Templater::ArgumentError, 'this is not a valid monkey, bad monkey!')
  end

end

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

describe Templater::Generator, '.argument as array' do

  before do
    @generator_class = Class.new(Templater::Generator)
    @generator_class.argument(0, :monkey)
    @generator_class.argument(1, :llama, :as => :array)
  end
  
  it "should allow assignment of arrays" do
    instance = @generator_class.new('/tmp', {}, 'a monkey', %w(an array))
    
    instance.monkey.should == 'a monkey'
    instance.llama[0].should == 'an'
    instance.llama[1].should == 'array'
    
    instance.llama = %w(another donkey)
    instance.llama[0].should == 'another'
    instance.llama[1].should == 'donkey'
  end
  
  it "should convert a single argument to an array" do
    instance = @generator_class.new('/tmp', {}, 'a monkey', 'test')
    instance.llama[0].should == 'test'
  end
  
  it "should consume the remaining arguments and convert them to an array" do
    instance = @generator_class.new('/tmp', {}, 'a monkey', 'test', 'silver', 'river')
    instance.llama[0].should == 'test'
    instance.llama[1].should == 'silver'
    instance.llama[2].should == 'river'
  end
  
  it "should raise error if the argument is not an array" do
    instance = @generator_class.new('/tmp')
    lambda { instance.llama = :not_an_array }.should raise_error(Templater::MalformattedArgumentError)
  end

end

describe Templater::Generator, '.template' do

  before do
    @generator_class = Class.new(Templater::Generator)
  end

  it "should add a template with source and destination" do
    @generator_class.template(:my_template, 'path/to/source.rbt', 'path/to/destination.rb')
    @instance = @generator_class.new('/tmp/destination')
    
    @instance.stub!(:source_root).and_return('/tmp/source')
    
    @instance.template(:my_template).source.should == '/tmp/source/path/to/source.rbt'
    @instance.template(:my_template).destination.should == '/tmp/destination/path/to/destination.rb'
    @instance.template(:my_template).should be_an_instance_of(Templater::Template)
  end
  
  it "should add a template with absolute source and destination" do
    @generator_class.template(:my_template, '/path/to/source.rbt', '/path/to/destination.rb')
    @instance = @generator_class.new('/tmp/destination')
    
    @instance.stub!(:source_root).and_return('/tmp/source')
    
    @instance.template(:my_template).source.should == '/path/to/source.rbt'
    @instance.template(:my_template).destination.should == '/path/to/destination.rb'
    @instance.template(:my_template).should be_an_instance_of(Templater::Template)
  end
  
  it "should add a template with destination and infer the source" do
    @generator_class.template(:my_template, 'path/to/destination.rb')
    @instance = @generator_class.new('/tmp/destination')
    
    @instance.stub!(:source_root).and_return('/tmp/source')
    
    @instance.template(:my_template).source.should == '/tmp/source/path/to/destination.rbt'
    @instance.template(:my_template).destination.should == '/tmp/destination/path/to/destination.rb'
    @instance.template(:my_template).should be_an_instance_of(Templater::Template)
  end
  
  it "should add a template with a block" do
    @generator_class.template(:my_template) do
      source 'blah.rbt'
      destination "gurr#{Process.pid.to_s}.rb"
    end
    @instance = @generator_class.new('/tmp/destination')
    
    @instance.stub!(:source_root).and_return('/tmp/source')
    
    @instance.template(:my_template).source.should == '/tmp/source/blah.rbt'
    @instance.template(:my_template).destination.should == "/tmp/destination/gurr#{Process.pid.to_s}.rb"
    @instance.template(:my_template).should be_an_instance_of(Templater::Template)
  end
  
  it "should add a template and convert an with an instruction encoded in the destination, but not one encoded in the source" do
    @generator_class.template(:my_template, 'template/%some_method%.rbt', 'template/%another_method%.rb')
    @instance = @generator_class.new('/tmp/destination')
    
    @instance.stub!(:source_root).and_return('/tmp/source')
    @instance.should_not_receive(:some_method)
    @instance.should_receive(:another_method).at_least(:once).and_return('beast')
    
    @instance.template(:my_template).source.should == '/tmp/source/template/%some_method%.rbt'
    @instance.template(:my_template).destination.should == "/tmp/destination/template/beast.rb"
    @instance.template(:my_template).should be_an_instance_of(Templater::Template)
  end
  
end

describe Templater::Generator, '.file' do

  before do
    @generator_class = Class.new(Templater::Generator)
  end

  it "should add a file with source and destination" do
    @generator_class.file(:my_template, 'path/to/source.rbt', 'path/to/destination.rb')
    @instance = @generator_class.new('/tmp/destination')
    
    @instance.stub!(:source_root).and_return('/tmp/source')
    
    @instance.file(:my_template).source.should == '/tmp/source/path/to/source.rbt'
    @instance.file(:my_template).destination.should == '/tmp/destination/path/to/destination.rb'
    @instance.file(:my_template).should be_an_instance_of(Templater::File)
  end
  
  it "should add a file with source and infer destination " do
    @generator_class.file(:my_template, 'path/to/file.rb')
    @instance = @generator_class.new('/tmp/destination')
    
    @instance.stub!(:source_root).and_return('/tmp/source')
    
    @instance.file(:my_template).source.should == '/tmp/source/path/to/file.rb'
    @instance.file(:my_template).destination.should == '/tmp/destination/path/to/file.rb'
    @instance.file(:my_template).should be_an_instance_of(Templater::File)
  end
  
end

describe Templater::Generator, '.invoke' do

  before do
    @generator_class = Class.new(Templater::Generator)
    @generator_class.first_argument :test1
    @generator_class.second_argument :test2
    
    @invoked_generator = mock('an invoked generator')
    @invoked_instance = mock('an instance of the invoked generator')
    @invoked_generator.stub!(:new).and_return(@invoked_instance)
    
    @manifold = mock('a manifold')
    @manifold.stub!(:generator).with(:test).and_return(@invoked_generator)
  end

  it "should add nothing if there is no manifold" do
    @generator_class.invoke(:test)
    @instance = @generator_class.new('/tmp', {}, 'test', 'argument')

    @instance.invocations.should be_empty
  end

  describe "with no block" do
    
    before(:each) do
      @generator_class.stub!(:manifold).and_return(@manifold)
    end
    
    it "should return the instantiaded template" do
      @generator_class.invoke(:test)
      @instance = @generator_class.new('/tmp', {}, 'test', 'argument')

      @instance.invocations.first.should == @invoked_instance
    end
    
    it "should ask the manifold for the generator" do
      @generator_class.should_receive(:manifold).at_least(:once).and_return(@manifold)
      @manifold.should_receive(:generator).with(:test).and_return(@invoked_generator)
      @generator_class.invoke(:test)
      @instance = @generator_class.new('/tmp', {}, 'test', 'argument')
      
      @instance.invocations.first.should == @invoked_instance
    end
    
    it "should instantiate the generator with the correct arguments" do
      @invoked_generator.should_receive(:new).with('/tmp', {}, 'test', 'argument').and_return(@invoked_instance)
      @generator_class.invoke(:test)
      @instance = @generator_class.new('/tmp', {}, 'test', 'argument')
      
      @instance.invocations.first.should == @invoked_instance
    end
    
  end
  
  describe "with a block" do
    
    before(:each) do
      @generator_class.stub!(:manifold).and_return(@manifold)
    end
    
    it "should pass the generator class to the block and return the result of it" do    
      @generator_class.invoke(:test) do |generator|
        generator.new(destination_root, options, 'blah', 'monkey', some_method)
      end
      @instance = @generator_class.new('/tmp', {}, 'test', 'argument')
      
      @instance.should_receive(:some_method).and_return('da')
      @invoked_generator.should_receive(:new).with('/tmp', {}, 'blah', 'monkey', 'da').and_return(@invoked_instance)
      
      @instance.invocations.first.should == @invoked_instance
    end
    
    it "should ask the manifold for the generator" do
      @generator_class.should_receive(:manifold).at_least(:once).and_return(@manifold)
      @manifold.should_receive(:generator).with(:test).and_return(@invoked_generator)
      
      @generator_class.invoke(:test) do |generator|
        generator.new(destination_root, options, 'blah', 'monkey')
      end

      @instance = @generator_class.new('/tmp', {}, 'test', 'argument')      
      @instance.invocations.first.should == @invoked_instance
    end
    
  end
  
end

describe Templater::Generator, '.template_list' do
  
  it "should add a series of templates given a list as heredoc" do
    @generator_class = Class.new(Templater::Generator)
    
    @generator_class.should_receive(:template).with(:app_model_rb, 'app/model.rb')
    @generator_class.should_receive(:template).with(:spec_model_rb, 'spec/model.rb')
    @generator_class.should_receive(:template).with(:donkey_poo_css, 'donkey/poo.css')
    @generator_class.should_receive(:template).with(:john_smith_file_rb, 'john/smith/file.rb')
    
    @generator_class.template_list <<-LIST
      app/model.rb
      spec/model.rb
      donkey/poo.css
      john/smith/file.rb
    LIST
  end
  
  it "should add a series of templates given a list as array" do
    @generator_class = Class.new(Templater::Generator)
    
    @generator_class.should_receive(:template).with(:app_model_rb, 'app/model.rb')
    @generator_class.should_receive(:template).with(:spec_model_rb, 'spec/model.rb')
    @generator_class.should_receive(:template).with(:donkey_poo_css, 'donkey/poo.css')
    @generator_class.should_receive(:template).with(:john_smith_file_rb, 'john/smith/file.rb')
    
    @generator_class.template_list(%w(app/model.rb spec/model.rb donkey/poo.css john/smith/file.rb))
  end
  
end

describe Templater::Generator, '.file_list' do
  
  it "should add a series of files given a list as heredoc" do
    @generator_class = Class.new(Templater::Generator)
    
    @generator_class.should_receive(:file).with(:app_model_rb, 'app/model.rb')
    @generator_class.should_receive(:file).with(:spec_model_rb, 'spec/model.rb')
    @generator_class.should_receive(:file).with(:donkey_poo_css, 'donkey/poo.css')
    @generator_class.should_receive(:file).with(:john_smith_file_rb, 'john/smith/file.rb')
    
    @generator_class.file_list <<-LIST
      app/model.rb
      spec/model.rb
      donkey/poo.css
      john/smith/file.rb
    LIST
  end
  
  it "should add a series of files given a list as array" do
    @generator_class = Class.new(Templater::Generator)
    
    @generator_class.should_receive(:file).with(:app_model_rb, 'app/model.rb')
    @generator_class.should_receive(:file).with(:spec_model_rb, 'spec/model.rb')
    @generator_class.should_receive(:file).with(:donkey_poo_css, 'donkey/poo.css')
    @generator_class.should_receive(:file).with(:john_smith_file_rb, 'john/smith/file.rb')
    
    @generator_class.file_list(%w(app/model.rb spec/model.rb donkey/poo.css john/smith/file.rb))
  end
  
end

describe Templater::Generator, '.glob!' do
  
  before do
    @generator_class = Class.new(Templater::Generator)
    @generator_class.stub!(:source_root).and_return(template_path('glob'))
  end
  
  it "should add templates and files in the source_root based on if their extensions are in the template_extensions array" do
    @generator_class.glob!()
    
    @instance = @generator_class.new('/tmp/destination')
    
    @instance.template(:arg_js).source.should == template_path('glob/arg.js')
    @instance.template(:arg_js).destination.should == "/tmp/destination/arg.js"

    @instance.template(:test_rb).source.should == template_path('glob/test.rb')
    @instance.template(:test_rb).destination.should == "/tmp/destination/test.rb"
    
    @instance.file(:subfolder_jessica_alba_jpg).source.should == template_path('glob/subfolder/jessica_alba.jpg')
    @instance.file(:subfolder_jessica_alba_jpg).destination.should == '/tmp/destination/subfolder/jessica_alba.jpg'
  end
  
  it "should add templates and files with a different template_extensions array" do
    @generator_class.glob!(nil, %w(jpg))
    
    @instance = @generator_class.new('/tmp/destination')
    
    @instance.file(:arg_js).source.should == template_path('glob/arg.js')
    @instance.file(:arg_js).destination.should == "/tmp/destination/arg.js"

    @instance.file(:test_rb).source.should == template_path('glob/test.rb')
    @instance.file(:test_rb).destination.should == "/tmp/destination/test.rb"
    
    @instance.template(:subfolder_jessica_alba_jpg).source.should == template_path('glob/subfolder/jessica_alba.jpg')
    @instance.template(:subfolder_jessica_alba_jpg).destination.should == '/tmp/destination/subfolder/jessica_alba.jpg'
  end
  
  it "should glob in a subdirectory" do
    @generator_class.stub!(:source_root).and_return(template_path(""))
    @generator_class.glob!('glob', %w(jpg))
    
    @instance = @generator_class.new('/tmp/destination')
    
    @instance.file(:glob_arg_js).source.should == template_path('glob/arg.js')
    @instance.file(:glob_arg_js).destination.should == "/tmp/destination/glob/arg.js"

    @instance.file(:glob_test_rb).source.should == template_path('glob/test.rb')
    @instance.file(:glob_test_rb).destination.should == "/tmp/destination/glob/test.rb"
    
    @instance.template(:glob_subfolder_jessica_alba_jpg).source.should == template_path('glob/subfolder/jessica_alba.jpg')
    @instance.template(:glob_subfolder_jessica_alba_jpg).destination.should == '/tmp/destination/glob/subfolder/jessica_alba.jpg'
  end
  
  it "should add only the given templates and files" do
    @generator_class.glob!()
    
    @instance = @generator_class.new('/tmp/destination')
    
    @instance.templates.map { |t| t.name }.should == [
      :arg_js,
      :subfolder_monkey_rb,
      :test_rb,
    ]
    @instance.files.map { |f| f.name }.should == [
      :readme,
      :subfolder_jessica_alba_jpg
    ]
  end
  
end

describe Templater::Generator, '.option' do

  before do
    @generator_class = Class.new(Templater::Generator)
  end

  it "should add accessors" do
    @generator_class.option(:test)

    instance = @generator_class.new('/tmp')
    
    instance.test = "monkey"
    instance.test.should == "monkey"
    
  end
  
  it "should preset a default value" do
    @generator_class.option(:test, :default => 'elephant')

    instance = @generator_class.new('/tmp')
  
    instance.test.should == "elephant"  
  end
  
  it "should allow overwriting of default values" do
    @generator_class.option(:test, :default => 'elephant')

    instance = @generator_class.new('/tmp')
  
    instance.test.should == "elephant"  
    instance.test = "monkey"  
    instance.test.should == "monkey"  
  end
  
  it "should allow passing in of options on generator creation" do
    @generator_class.option(:test, :default => 'elephant')

    instance = @generator_class.new('/tmp', { :test => 'freebird' })
  
    instance.test.should == "freebird"  
    instance.test = "monkey"  
    instance.test.should == "monkey"  
  end
end

describe Templater::Generator, '.generators' do

  before do
    @generator_class = Class.new(Templater::Generator)
    
    @g1 = Class.new(Templater::Generator)
    @g2 = Class.new(Templater::Generator)
    @g3 = Class.new(Templater::Generator)
    @g4 = Class.new(Templater::Generator)

    @manifold = mock('a manifold')
    @manifold.stub!(:generator).with(:monkey).and_return(@g1)
    @manifold.stub!(:generator).with(:blah).and_return(@g2)
    @manifold.stub!(:generator).with(:duck).and_return(@g3)
    @manifold.stub!(:generator).with(:llama).and_return(@g4)
    @manifold.stub!(:generator).with(:i_dont_exist).and_return(nil)

    @generator_class.manifold = @manifold
    @g1.manifold = @manifold
    @g2.manifold = @manifold
    @g3.manifold = @manifold
    @g4.manifold = @manifold
  end

  it "should return [self] when no manifold or invocations exist" do
    @generator_class.manifold = nil
    @generator_class.generators.should == [@generator_class]
  end
  
  it "should return [self] when only invocations exist" do
    @generator_class.manifold = nil
    @generator_class.invoke(:monkey)
    @generator_class.invoke(:blah)
    @generator_class.generators.should == [@generator_class]
  end
  
  it "should return a list of invoked generators" do        
    @generator_class.invoke(:monkey)
    @generator_class.invoke(:blah)
    
    @generator_class.generators.should == [@generator_class, @g1, @g2]
  end
  
  it "should return a list of invoked generators recursively" do
    @generator_class.invoke(:monkey)
    @generator_class.invoke(:blah)
    @g1.invoke(:duck)
    @g3.invoke(:llama)
    
    @generator_class.generators.should == [@generator_class, @g1, @g3, @g4, @g2]
  end
  
  it "should ignore invocations that do not exist in the manifold" do
    @generator_class.invoke(:monkey)
    @generator_class.invoke(:blah)
    @g1.invoke(:duck)
    @g3.invoke(:i_dont_exist)
    
    @generator_class.generators.should == [@generator_class, @g1, @g3, @g2]
  end
end

describe Templater::Generator, '.source_root' do
  it "should raise an error, complaining that source_root must be overridden" do
    @generator_class = Class.new(Templater::Generator)    
    lambda { @generator_class.source_root }.should raise_error(Templater::SourceNotSpecifiedError)
  end
end

describe Templater::Generator, '#template' do

  before do
    @generator_class = Class.new(Templater::Generator)
    @generator_class.class_eval do
      def source_root
        '/tmp/source'
      end
    end
  end

  it "should find a template by name" do
    @generator_class.template(:blah1, 'blah.rb')
    @generator_class.template(:blah2, 'blah2.rb')
    
    instance = @generator_class.new('/tmp')
    
    instance.template(:blah1).name.should == :blah1
    instance.template(:blah1).source.should == '/tmp/source/blah.rbt'
    instance.template(:blah1).destination.should == '/tmp/blah.rb'
  end
  
  it "should not return a template with an option that does not match." do
    @generator_class.option :framework, :default => :rails
    
    @generator_class.template(:merb, 'blah.rb', :framework => :merb)
    @generator_class.template(:rails, 'blah2.rb', :framework => :rails)
    @generator_class.template(:none, 'blah2.rb')
    
    instance = @generator_class.new('/tmp')

    instance.template(:rails).name.should == :rails
    instance.template(:merb).should be_nil
    instance.template(:none).name.should == :none

    instance.framework = :merb
    instance.template(:rails).should be_nil
    instance.template(:merb).name.should == :merb
    instance.template(:none).name.should == :none

    instance.framework = nil
    instance.template(:rails).should be_nil
    instance.template(:merb).should be_nil
    instance.template(:none).name.should == :none
  end
end

describe Templater::Generator, '#templates' do

  before do
    @generator_class = Class.new(Templater::Generator)
    @generator_class.class_eval do
      def source_root
        '/tmp/source'
      end
    end
  end

  it "should return all templates" do
    @generator_class.template(:blah1, 'blah.rb')
    @generator_class.template(:blah2, 'blah2.rb')
    
    instance = @generator_class.new('/tmp')
    
    instance.templates[0].name.should == :blah1
    instance.templates[1].name.should == :blah2
  end
  
  it "should not return templates with an option that does not match." do
    @generator_class.option :framework, :default => :rails
    
    @generator_class.template(:merb, 'blah.rb', :framework => :merb)
    @generator_class.template(:rails, 'blah2.rb', :framework => :rails)
    @generator_class.template(:none, 'blah2.rb')
    
    instance = @generator_class.new('/tmp')

    instance.templates[0].name.should == :rails
    instance.templates[1].name.should == :none

    instance.framework = :merb
    instance.templates[0].name.should == :merb
    instance.templates[1].name.should == :none

    instance.framework = :rails
    instance.templates[0].name.should == :rails
    instance.templates[1].name.should == :none
    
    instance.framework = nil
    instance.templates[0].name.should == :none
  end
end

describe Templater::Generator, '#file' do

  before do
    @generator_class = Class.new(Templater::Generator)
    @generator_class.class_eval do
      def source_root
        '/tmp/source'
      end
    end
  end

  it "should find a file by name" do
    @generator_class.file(:blah1, 'blah.rb')
    @generator_class.file(:blah2, 'blah2.rb')
    
    instance = @generator_class.new('/tmp')
    
    instance.file(:blah1).name.should == :blah1
    instance.file(:blah1).source.should == '/tmp/source/blah.rb'
    instance.file(:blah1).destination.should == '/tmp/blah.rb'
  end
  
  it "should not return a file with an option that does not match." do
    @generator_class.option :framework, :default => :rails
    
    @generator_class.file(:merb, 'blah.rb', :framework => :merb)
    @generator_class.file(:rails, 'blah2.rb', :framework => :rails)
    @generator_class.file(:none, 'blah2.rb')
    
    instance = @generator_class.new('/tmp')

    instance.file(:rails).name.should == :rails
    instance.file(:merb).should be_nil
    instance.file(:none).name.should == :none

    instance.framework = :merb
    instance.file(:rails).should be_nil
    instance.file(:merb).name.should == :merb
    instance.file(:none).name.should == :none

    instance.framework = nil
    instance.file(:rails).should be_nil
    instance.file(:merb).should be_nil
    instance.file(:none).name.should == :none
  end
end

describe Templater::Generator, '#files' do

  before do
    @generator_class = Class.new(Templater::Generator)
    @generator_class.class_eval do
      def source_root
        '/tmp/source'
      end
    end
  end

  it "should return all files" do
    @generator_class.file(:blah1, 'blah.rb')
    @generator_class.file(:blah2, 'blah2.rb')
    
    instance = @generator_class.new('/tmp')
    
    instance.files[0].name.should == :blah1
    instance.files[1].name.should == :blah2
  end
  
  it "should not return files with an option that does not match." do
    @generator_class.option :framework, :default => :rails
    
    @generator_class.file(:merb, 'blah.rb', :framework => :merb)
    @generator_class.file(:rails, 'blah2.rb', :framework => :rails)
    @generator_class.file(:none, 'blah2.rb')
    
    instance = @generator_class.new('/tmp')

    instance.files[0].name.should == :rails
    instance.files[1].name.should == :none

    instance.framework = :merb
    instance.files[0].name.should == :merb
    instance.files[1].name.should == :none

    instance.framework = :rails
    instance.files[0].name.should == :rails
    instance.files[1].name.should == :none
    
    instance.framework = nil
    instance.files[0].name.should == :none
  end
end

describe Templater::Generator, '#invocations' do

  before do
    @generator_class = Class.new(Templater::Generator)
    @generator_class.class_eval do
      def source_root
        '/tmp/source'
      end
    end
    
    @generator1 = mock('a generator for merb')
    @instance1 = mock('an instance of the generator for merb')
    @generator1.stub!(:new).and_return(@instance1)
    @generator2 = mock('a generator for rails')
    @instance2 = mock('an instance of the generator for rails')
    @generator2.stub!(:new).and_return(@instance2)
    @generator3 = mock('a generator for both')
    @instance3 = mock('an instance of the generator for both')
    @generator3.stub!(:new).and_return(@instance3)
    
    @manifold = mock('a manifold')
    @manifold.stub!(:generator).with(:merb).and_return(@generator1)
    @manifold.stub!(:generator).with(:rails).and_return(@generator2)
    @manifold.stub!(:generator).with(:both).and_return(@generator3)
    
    @generator_class.stub!(:manifold).and_return(@manifold)
  end

  it "should return all invocations" do
    @generator_class.invoke(:merb)
    @generator_class.invoke(:rails)
    
    instance = @generator_class.new('/tmp')
    
    instance.invocations[0].should == @instance1
    instance.invocations[1].should == @instance2
  end
  
  it "should not return templates with an option that does not match." do
    @generator_class.option :framework, :default => :rails
    
    @generator_class.invoke(:merb, :framework => :merb)
    @generator_class.invoke(:rails, :framework => :rails)
    @generator_class.invoke(:both)
    
    instance = @generator_class.new('/tmp')

    instance.invocations[0].should == @instance2
    instance.invocations[1].should == @instance3
                                      
    instance.framework = :merb        
    instance.invocations[0].should == @instance1
    instance.invocations[1].should == @instance3

    instance.framework = :rails       
    instance.invocations[0].should == @instance2
    instance.invocations[1].should == @instance3

    instance.framework = nil          
    instance.invocations[0].should == @instance3
  end
end

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
  end
  
end

describe Templater::Generator, '#invoke!' do

  before do
    @generator_class = Class.new(Templater::Generator)
  end

  it "should invoke all templates" do
    template1 = mock('a template')
    template2 = mock('another template')
    
    instance = @generator_class.new('/tmp')
    
    instance.should_receive(:templates).and_return([template1, template2])
    template1.should_receive(:invoke!)
    template2.should_receive(:invoke!)

    instance.invoke!
  end
end

describe Templater::Generator, '#destination_root' do
  it "should be remembered" do
    @generator_class = Class.new(Templater::Generator)
    instance = @generator_class.new('/path/to/destination')
    instance.destination_root.should == '/path/to/destination'
  end
end

describe Templater::Generator, '#source_root' do
  it "try to retrieve the source root from the class" do
    @generator_class = Class.new(Templater::Generator)
    @generator_class.should_receive(:source_root).and_return('/tmp/source')

    instance = @generator_class.new('/tmp')
    instance.source_root.should == '/tmp/source'
  end
end