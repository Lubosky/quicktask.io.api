class ClientRequest::Translation < ClientRequest
  set_request_type :translation

  validates :source_language, :target_language_ids, presence: true

  def target_language_ids=(value)
    collection_ids = self.workspace.languages.where(id: value).ids
    collection_ids = collection_ids.without(source_language_id)
    write_attribute(:target_language_ids, collection_ids)
  end
end
