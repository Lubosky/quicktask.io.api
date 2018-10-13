class Tagged::TagNames
  def self.call(names)
    return nil if names.nil?

    names.reject(&:blank?)
  end
end
