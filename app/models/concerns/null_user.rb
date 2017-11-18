module NullUser
  NIL_METHODS   = [:uuid, :email, :google_uid, :password_digest, :deactivated_at,
                   :last_login_at, :first_name, :last_name, :deactivated_at, :locale,
                   :time_zone, :avatar_data, :token_payload, :to_token_payload]
  FALSE_METHODS = [:email_confirmed, :confirmed?, :deactivated?, :pending?]
  EMPTY_METHODS = [:members, :owned_memberships, :owned_workspaces]
  TRUE_METHODS  = []
  NONE_METHODS  = [:workspaces, :tokens]

  NIL_METHODS.each   { |method| define_method(method, -> { nil }) }
  FALSE_METHODS.each { |method| define_method(method, -> { false }) }
  EMPTY_METHODS.each { |method| define_method(method, -> { [] }) }
  TRUE_METHODS.each  { |method| define_method(method, -> { true }) }
  NONE_METHODS.each  { |method| define_method(method, -> { method.to_s.singularize.classify.constantize.none }) }

  def language
    I18n.locale
  end

  def settings
    {}
  end
end
