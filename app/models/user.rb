class User < ApplicationRecord
  include EmailNormalizer, EnsureUUID

  attr_reader :password

  has_secure_password

  with_options dependent: :restrict_with_error, foreign_key: :owner_id, inverse_of: :owner do
    has_many :owned_workspaces, class_name: 'Workspace'
    has_many :owned_memberships, class_name: 'Membership'
  end

  has_many :accounts, class_name: 'WorkspaceAccount', foreign_key: :user_id
  has_many :workspaces,
           through: :accounts,
           class_name: 'Workspace',
           foreign_key: :workspace_id
  has_many :tokens, foreign_key: :subject_id, dependent: :delete_all

  validates :email, email: true, presence: true, uniqueness: true
  validates :locale, :time_zone, presence: true
  validates :google_uid,
            presence: true,
            uniqueness: true,
            unless: :skip_google_uid_validation?

  validates :password,
            confirmation: true,
            length: { minimum: 8 },
            unless: :skip_password_validation?

  validate :password_or_google_uid_present

  after_save :synchronize_common_attributes, if: :common_attributes_changed?

  jsonb_accessor :settings,
    time_twelve_hour: [:boolean, default: false]

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

  def password_matches?(password)
    if self.password_automatically_set?
      ::BCrypt::Password.create(password)
      true
    elsif password_digest.present?
      ::BCrypt::Password.new(self.password_digest) == password
    else
      ::BCrypt::Password.create(password)
      false
    end
  end

  def reset_password(new_password, new_password_confirmation)
    self.password = new_password
    self.password_confirmation = new_password_confirmation
    self.password_automatically_set = false
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

  def synchronize_common_attributes
    self.accounts.
      includes(:account, :user).
      find_each(&:synchronize_common_attributes)
  end

  private

  def common_attributes_changed?
    saved_change_to_first_name? ||
      saved_change_to_last_name? ||
      saved_change_to_email?
  end

  def skip_google_uid_validation?
    password_digest.present? ||
      (google_uid.present? && !google_uid_changed?)
  end

  def skip_password_validation?
    password_digest.present? && !password_digest_changed?
  end

  def password_or_google_uid_present
    if password_digest.blank? && google_uid.blank?
      errors.add :base, 'Either password or Google account ID must be present.'
    end
  end
end
