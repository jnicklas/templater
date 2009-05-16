require File.dirname(__FILE__) + '/../spec_helper'

describe Templater::Generator do

  before do
    @generator_class = Class.new(Templater::Generator)
    @generator = @generator_class.new('/tmp')
  end

  describe '#actions' do
    it "should evaluate recipes and return actions added in them" do
      mock_action = mock('an action')
      @generator_class.recipe(:foo) do
        action(mock_action)
      end
      @generator.actions[0].should == mock_action
    end

    it "should not persist actions between multiple calls" do
      mock_action = mock('an action')
      @generator_class.recipe(:foo) do
        action(mock_action)
      end
      5.times { @generator.actions }
      @generator.actions.size.should == 1
    end

    it "should be possible to add recipes dynamically" do
      mock_action = mock('an action')
      second_mock_action = mock('anonther action')
      @generator_class.recipe(:foo) do
        action(mock_action)
      end
      @generator.actions.size.should == 1
      @generator_class.recipe(:bar) do
        action(second_mock_action)
      end
      @generator.actions.size.should == 2
    end
  end

end
