module TagNormalizer
  def self.normalizer
    @normalizer ||= lambda { |tag_name| tag_name.to_s.downcase }
  end

  def self.normalizer=(normalizer)
    @normalizer = normalizer
  end
end
