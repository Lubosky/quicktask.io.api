module Config
  class Classification
    include ActiveModel::Serialization

    CLASSIFICATIONS = [
      { id: 'localization', title: 'Localization' },
      { id: 'interpreting', title: 'Interpreting' },
      { id: 'other', title: 'Other' },
      { id: 'translation', title: 'Translation' },
    ].freeze

    attr_reader :id, :title

    def initialize(id:, title:)
      @id = id
      @title = title
    end

    def self.all
      CLASSIFICATIONS.map { |entry| new(entry) }
    end

    def self.find(id)
      found = CLASSIFICATIONS.detect { |entry| entry[:id] == id }
      new(found)
    end

    def self.find_by(title:)
      found = CLASSIFICATIONS.detect { |entry| entry[:title] == title }
      new(found)
    end
  end
end
