require 'rails_helper'

RSpec.describe UserMailer do
  let(:user) { build(:user) }
  let(:token) { PasswordResetToken.generate_for(user).to_s }

  describe 'successful password change request' do
    subject { UserMailer.password_change_request(user: user, token: token) }

    its(:subject) { should eq I18n.t(:'email.password_change_request.subject') }
    its(:from) { should eq [Settings.app.default_email_address] }
    its(:to) { should eq [user.email] }

    it 'contains the password reset token' do
      expect(subject.body.encoded).to match(token)
    end
  end
end
