class User < ApplicationRecord
  include EmailNormalizer
  include EnsureUUID

  attr_reader :password

  has_secure_password validations: false

  validates :uuid, presence: true, uniqueness: true
  validates :email, email: { strict_mode: true }, presence: true, uniqueness: true
  validates :google_uid, presence: true, uniqueness: true, unless: :skip_google_uid_validation?
  validates :password, confirmation: true, length: { minimum: 8 }, unless: :skip_password_validation?
  validate :password_or_google_uid_present

  has_many :tokens, foreign_key: :subject_id, dependent: :delete_all

  def password=(value)
    password_digest_will_change!
    super
  end

  def language
    locale || I18n.default_locale
  end

  def token_payload
    tokens.create.token_payload
  end

  def to_token_payload
    token_payload.merge(sub: id)
  end

  def track_successful_login
    self.last_login_at = Time.current.utc
    save(validate: false)
  end

  def reset_password(new_password, new_password_confirmation)
    self.password = new_password
    self.password_confirmation = new_password_confirmation
    save
  end

  def confirmed?
    email_confirmed.present?
  end

  def deactivated?
    deactivated_at.present?
  end

  def pending?
    !confirmed? && !deactivated?
  end

  def status
    if deactivated? then :inactive
    elsif pending? then :pending
    else :active
    end
  end

  private

  def password_optional?
    google_uid.present?
  end

  def skip_password_validation?
    password_optional? ||
      (password_digest.present? && !password_digest_changed?)
  end

  def skip_google_uid_validation?
    password_digest.present? ||
      (google_uid.present? && !google_uid_changed?)
  end

  def password_or_google_uid_present
    if password_digest.blank? && google_uid.blank?
      errors.add :base, 'Either password or Google account ID must be present.'
    end
  end
end
