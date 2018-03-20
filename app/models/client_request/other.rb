class ClientRequest::Other < ClientRequest
  set_request_type :other

  before_validation { self.source_language = nil }

  def target_language_ids=(value)
    write_attribute(:target_language_ids, [])
  end
end
