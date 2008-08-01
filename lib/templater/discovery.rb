# Templater::Discovery is used to find generators from plugins

module Templater
  
  module Discovery
    
    extend self
    
    def scope(scope, &block)
      @scopes[scope] ||= []
      @scopes[scope] << block
    end
    
    def discover!(scope)
      @scopes = {}
      generator_files.each do |file|
        load file
      end
      @scopes[scope].each { |block| block.call } if @scopes[scope]
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
        path = ::File.join(gem.full_gem_path, "Generators")
        files << path if ::File.exists?(path) and not ::File.directory?(path)
        files
      end
    end
    
  end

end

def scope(scope, &block)
  Templater::Discovery.scope(scope, &block)
end