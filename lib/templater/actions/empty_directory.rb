module Templater
  class EmptyDirectory

    attr_reader :name, :destination
    
    def initialize(name, destination)
      @name, @destination = name, destination
    end

    # Returns the destination path relative to Dir.pwd. This is useful for prettier output in interfaces
    # where the destination root is Dir.pwd.
    #
    # === Returns
    # String:: The destination relative to Dir.pwd
    def relative_destination
      @destination.sub(::Dir.pwd + ::File::SEPARATOR, '')
    end

    # Returns the contents of the source file as a String
    #
    # === Returns
    # String:: The source file.
    def render
      ::File.read(source)
    end

    # Checks if the destination file already exists.
    #
    # === Returns
    # Boolean:: true if the file exists, false otherwise.
    def exists?
      ::File.exists?(destination)
    end
  
    # For empty directory this is in fact alias for exists? method.
    # 
    # === Returns
    # Boolean:: true if it is identical, false otherwise.
    def identical?
      exists?
    end
  
    # Renders the template and copies it to the destination.
    def invoke!
      ::FileUtils.mkdir_p(destination)
    end
    
    # removes the destination file
    def revoke!
      ::FileUtils.rm_rf(::File.expand_path(destination))
    end
  end # EmptyDirectory
end # Templater
