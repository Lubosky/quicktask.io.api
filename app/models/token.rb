class Token < ApplicationRecord
  CLAIMS = %w(exp iat jti)

  belongs_to :user, class_name: 'User', foreign_key: :subject_id

  after_initialize do
    if new_record?
      self.expiry_date = Time.current + AuthenticationToken.token_expiry_time
      self.issued_at = Time.current
    end
  end

  after_create { self.user.track_successful_login }

  alias_attribute :exp, :expiry_date
  alias_attribute :iat, :issued_at
  alias_attribute :jti, :id

  def token_payload
    CLAIMS.each_with_object({}) { |a, h| h[a] = send(a) }
  end

  private

  def exp
    expiry_date.to_i
  end

  def iat
    issued_at.to_i
  end

  def jti
    id.to_s
  end
end
