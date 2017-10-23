class BaseMailer < ActionMailer::Base
  include ApplicationHelper
  include EmailHelper

  before_action :utm_hash
  default from: "#{Settings.app.name} <#{Settings.app.default_email_address}>",
          template_path: Proc.new { self.class.name.gsub(/Mailer$/, '').underscore }
  layout 'mailer'
  prepend_view_path ['app/views/mailers']

  protected

  def locale_for(*user)
    [*user, I18n].compact.first.language
  end

  def send_single_email(locale:, to:, subject_key:, subject_params: {}, **options)
    I18n.with_locale(locale) do
      mail options.merge(to: to,
                         subject: I18n.t(subject_key, subject_params))
    end
  end

  def self.send_bulk_email(to:)
    to.each { |user| yield user if block_given? }
  end

  def utm_hash
    @utm_hash = { utm_campaign: mailer_name, utm_medium: 'email', utm_source: action_name }
  end
end
