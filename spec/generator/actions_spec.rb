require File.dirname(__FILE__) + '/../spec_helper'

describe Templater::Generator do

  def action_like_class(status=:ok)
    Class.new(Struct.new(:generator)) do
      define_method(:status) { status }
      define_method(:invoke!) { foo }
      define_method(:revoke!) { bar }
    end
  end

  before do
    @generator_class = Class.new(Templater::Generator)
    @generator = @generator_class.new('/tmp')
  end

  describe '#actions' do
    it "should evaluate recipes and return actions added in them" do
      action_class = action_like_class
      @generator_class.recipe(:foo) do
        action(action_class)
      end
      @generator.actions[0].should be_an_instance_of(action_class)
    end

    it "should not persist actions between multiple calls" do
      action_class = action_like_class
      @generator_class.recipe(:foo) do
        action(action_class)
      end
      5.times { @generator.actions }
      @generator.actions.size.should == 1
    end

    it "should be possible to add recipes dynamically" do
      action_class = action_like_class
      @generator_class.recipe(:foo) do
        action(action_class)
      end
      @generator.actions.size.should == 1
      @generator_class.recipe(:bar) do
        action(action_class)
      end
      @generator.actions.size.should == 2
    end
  end

end
