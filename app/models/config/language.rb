module Config
  Language = Struct.new :id, :name do
    include ActiveModel::Serialization

    LANGUAGES = AppConfig.languages.freeze

    def self.all
      LANGUAGES.map { |language| new(*language.values) }
    end

    def self.codes
      all.pluck(:id)
    end

    def self.find_by(id:)
      language = LANGUAGES.detect { |entry| entry[:id] == id }
      new(*language.values) if language
    end

    def <=>(other)
      name <=> other.name
    end
  end
end
