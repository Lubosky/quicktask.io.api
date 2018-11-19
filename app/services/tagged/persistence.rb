require 'forwardable'

class Tagged::Persistence
  extend Forwardable

  attr_writer :tagger

  def initialize(change_state)
    @change_state = change_state
  end

  def persist
    remove_old
    add_new
  end

  private

  attr_reader :change_state

  def_delegators :change_state, :taggable, :added, :removed
  def_delegator :taggable, :workspace

  def add_new
    added.each do |name|
      taggable.tags << tagger.find_or_create(name: name, workspace: workspace)
    end
  end

  def remove_old
    removed.each do |name|
      taggable.tags.delete tagger.find_by_name_and_workspace(name, workspace)
    end
  end

  def tagger
    @tagger ||= Tag
  end
end
