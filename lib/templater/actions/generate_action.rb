module Templater
  module Actions

    def generate(generator, *args)
      self.actions += generator.new(destination_root, *args).actions
    end

  end
end