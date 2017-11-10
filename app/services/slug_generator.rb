class SlugGenerator
  def initialize(name)
    @name = name
  end

  def self.slugify(name)
    new(name).slugify
  end

  def slugify
    return slug if taken_names.none?
    slug + '-' + next_sequence_number.to_s
  end

  private

  attr_accessor :name

  def slug
    ActiveSupport::Inflector.
      transliterate(name).
      downcase.
      parameterize[0, 18]
  end

  def next_sequence_number
    last_sequence_number ? last_sequence_number + 1 : 1
  end

  def last_sequence_number
    new_slug = /#{slug}-(\d+)\z/
    taken_names.reject{ |conflict| !new_slug.match(conflict) }.map do |conflict|
      new_slug.match(conflict)[1].to_i
    end.max
  end

  def taken_names
    @_taken_names ||= Workspace.
      where('slug = ? OR slug LIKE ?', slug, "#{slug + '%'}").
      order('LENGTH(slug) ASC, slug ASC').
      pluck(:slug)
  end
end
