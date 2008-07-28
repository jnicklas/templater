# Templater::Discovery is used to find generators from plugins

module Templater
  
  class Discovery
    
    def self.discover!(scope)
      self.new(scope).discover!
    end
    
    def initialize(scope)
      @scope = scope
    end
    
    def discover!
      generator_files.each do |file|
        file.load!
      end
    end
    
    protected
    
    def find_latest_gems
      Gem::cache.inject({}) do |latest_gems, cache|
        name, gem = cache
        currently_latest = latest_gems[gem.name]
        latest_gems[gem.name] = gem if currently_latest.nil? or gem.version > currently_latest.version
        latest_gems
      end.values
    end

    def generator_files
      find_latest_gems.inject([]) do |files, gem|
        path = File.join(gem.full_gem_path, "Generators")
        files << GeneratorFile.new(@scope, path) if File.exists?(path) and not File.directory?(path)
        files
      end
    end
    
  end
  
  class GeneratorFile #:nodoc:
    
    def initialize(scope, path)
      @scope, @path = scope, path
    end
    
    def scope(scope)
      yield if @scope == scope
    end
    
    def load!
      instance_eval(File.read(@path))
    end
    
  end

end