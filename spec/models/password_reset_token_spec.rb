require 'rails_helper'

RSpec.describe PasswordResetToken do
  describe '.generate_for' do
    it 'uses the configured message verifier to generate a token' do
      Timecop.freeze do
        user = mock('User', id: 1, password_digest: 'abcd1234')
        Vault.stubs(:encrypt).returns('SEKRET')

        token = PasswordResetToken.generate_for(user)

        expect(token.to_s).to eq 'SEKRET'
      end
    end
  end

  describe '#user' do
    it 'is the user if signature is valid and token is not expired' do
      user = create(:user)
      token = PasswordResetToken.generate_for(user)

      expect(token.user).to eq user
    end

    it 'is nil if the signature is invalid' do
      token = PasswordResetToken.new('FOO')

      expect(token.user).to be nil
    end

    it 'is nil if the signature is valid but expired' do
      user = mock('User', id: 1, password_digest: 'abcd1234')
      token = PasswordResetToken.generate_for(user)

      Timecop.freeze(1.day.from_now) do
        expect(token.user).to be nil
      end
    end

    it 'is nil if the signature is valid and unexpired but password has changed' do
      user = create(:user, password: 'abcd1234')
      token = PasswordResetToken.generate_for(user)
      user.update!(password: 'something_else')

      expect(token.user).to be nil
    end
  end
end
