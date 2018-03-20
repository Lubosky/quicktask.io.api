class ClientRequest::Localization < ClientRequest
  set_request_type :localization

  before_validation { self.source_language = nil }

  validates :target_language_ids, presence: true

  def target_language_ids=(value)
    collection_ids = self.workspace.languages.where(id: value).ids
    write_attribute(:target_language_ids, collection_ids)
  end
end
