class String
  
  def realign_indentation
    basis = self.index(/\S/) # find the first non-whitespace character
    return self.to_lines.map { |s| s[basis..-1] }.join
  end

  # Provides backward compatible way to get a collection of lines.  To avoid
  # overriding of the original each_line of ruby-1.8.6, we define new method
  # for that purpose.  Since defining to_a for ruby-1.9.1 is also bad idea,
  # even if it were necessary, it should not be to_a but such like to_lines
  # which is as follows.
  if RUBY_VERSION <= "1.8.6"
    def to_lines
      to_a
    end
  else
    def to_lines
      each_line.to_a
    end
  end
end
