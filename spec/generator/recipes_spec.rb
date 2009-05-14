require File.dirname(__FILE__) + '/../spec_helper'

describe Templater::Generator do

  before do
    @generator_class = Class.new(Templater::Generator)
    @generator = @generator_class.new('/tmp')
  end

  describe '.recipe' do

    it "should add a recipe" do
      @generator_class.recipe :model
      @generator.recipe(:model).name.should == :model
    end

    it "should add to the list of recipes" do
      @generator_class.recipe :model
      @generator.recipes.first.name.should == :model
    end

    it "should add to the list of recipe names" do
      @generator_class.recipe :model
      @generator.recipe_names.first.should == :model
    end

    it "should be in the list of recipes if an :if condition is true" do
      @generator_class.recipe :model, :if => :monkey?
      @generator.stub!(:monkey?).and_return(true)
      @generator.recipe_names.should include(:model)
    end

    it "should not be in the list of recipes if an :if condition is false" do
      @generator_class.recipe :model, :if => :monkey?
      @generator.stub!(:monkey?).and_return(false)
      @generator.recipe_names.should_not include(:model)
    end

    it "should be in the list of recipes if an :unless condition is false" do
      @generator_class.recipe :model, :unless => :monkey?
      @generator.stub!(:monkey?).and_return(false)
      @generator.recipe_names.should include(:model)
    end

    it "should not be in the list of recipes if an :unless condition is true" do
      @generator_class.recipe :model, :unless => :monkey?
      @generator.stub!(:monkey?).and_return(true)
      @generator.recipe_names.should_not include(:model)
    end

    it "should be in the list of recipes if an :unless condition is false and an :if condition is true" do
      @generator_class.recipe :model, :unless => :monkey?, :if => :red?
      @generator.stub!(:monkey?).and_return(false)
      @generator.stub!(:red?).and_return(true)
      @generator.recipe_names.should include(:model)
    end

    it "should not be in the list of recipes if an :unless condition is false and an :if condition is false" do
      @generator_class.recipe :model, :unless => :monkey?, :if => :red?
      @generator.stub!(:monkey?).and_return(false)
      @generator.stub!(:red?).and_return(false)
      @generator.recipe_names.should_not include(:model)
    end

  end

  describe ".use_recipe" do
    before do
      @generator_class.recipe :model
    end
    
    it "should remove the recipe from recipes list when false is passed" do
      @generator_class.use_recipe :model, false
      @generator.recipe_names.should_not include(:model)
    end
    
    it "should readd the recipe to the recipes list when false is passed and then true is passed" do
      @generator_class.use_recipe :model, false
      @generator_class.use_recipe :model, true
      @generator.recipe_names.should include(:model)
    end
    
    it "should be in the list of recipes if an :unless condition is false" do
      @generator_class.use_recipe :model, :unless => :monkey?
      @generator.stub!(:monkey?).and_return(false)
      @generator.recipe_names.should include(:model)
    end
    
  end

end
