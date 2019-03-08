require 'rails_helper'

RSpec.describe User, type: :model do
  subject { create(:user) }

  context 'validations' do
    before do
      User.any_instance.stubs(:ensure_uuid).returns(true)
    end

    it { should have_many(:tokens).dependent(:delete_all) }

    it { is_expected.to validate_presence_of(:uuid) }
    it { is_expected.to validate_uniqueness_of(:uuid) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).ignoring_case_sensitivity }
    it { is_expected.to validate_length_of(:password).is_at_least(8) }

    it { is_expected.to allow_value('').for(:password) }

    it { is_expected.to allow_value('foo@example.co.uk').for(:email) }
    it { is_expected.to allow_value('foo@example.com').for(:email) }
    it { is_expected.to allow_value('foo+bar@example.com').for(:email) }
    it { is_expected.not_to allow_value('foo@').for(:email) }
    it { is_expected.not_to allow_value('foo@example..com').for(:email) }
    it { is_expected.not_to allow_value('foo@.example.com').for(:email) }
    it { is_expected.not_to allow_value('foo').for(:email) }
    it { is_expected.not_to allow_value('example.com').for(:email) }
    it { is_expected.not_to allow_value('foo;@example.com').for(:email) }
  end

  describe '#email' do
    it 'stores email in down case and removes whitespace' do
      user = create(:user, email: 'Jo hn.Do e @exa mp le.c om')

      expect(user.email).to eq 'john.doe@example.com'
    end

    it 'is retrieved via a case-insensitive search' do
      user = create(:user)

      expect(User.find_by_normalized_email(user.email.upcase)).to eq(user)
    end
  end

  describe 'email address normalization' do
    it 'downcases the address and strips spaces' do
      email = 'Jo hn.Do e @exa mp le.c om'

      expect(User.normalize_email(email)).to eq 'john.doe@example.com'
    end
  end

  it 'validates presence of either :password_digest or :google_uid' do
    user_1 = build(:user, google_uid: nil, password_digest: nil)
    user_2 = build(:user, google_uid: nil, password_digest: 'abcd1234')
    user_3 = build(:user, google_uid: nil, password_digest: '1234abcd')

    expect(user_1).to_not be_valid
    expect(user_2).to be_valid
    expect(user_3).to be_valid
  end

  it 'validates presence of :password_digest if :google_uid is present' do
    user_1 = build(:user, google_uid: '123456789', password_digest: nil)
    user_2 = build(:user, google_uid: '987654321', password_digest: '1234abcd')

    expect(user_1).not_to be_valid
    expect(user_2).to be_valid
  end

  it 'skips validation of :google_uid presence if :password_digest is present' do
    user_1 = build(:user, google_uid: nil, password_digest: '1234abcd')
    user_2 = build(:user, google_uid: nil, password_digest: 'abcd1234')

    expect(user_1).to be_valid
    expect(user_2).to be_valid
  end

  describe '#reset_password' do
    context 'with a valid password' do
      it 'changes the encrypted password' do
        user = create(:user)
        old_password_digest = user.password_digest

        user.reset_password('new_password', 'new_password')

        expect(user.password_digest).not_to eq old_password_digest
      end
    end

    context 'with blank password' do
      it 'does not change the encrypted password' do
        user = create(:user)
        old_password_digest = user.password_digest

        user.reset_password('', '')

        expect(user.password_digest.to_s).to eq old_password_digest
      end
    end
  end

  describe 'the password setter on a User' do
    it 'sets password to the plain-text password' do
      password = 'password'
      subject.send(:password=, password)

      expect(subject.password).to eq password
    end

    it 'also sets password_digest' do
      password = 'password'
      subject.send(:password=, password)

      expect(subject.password_digest).to_not be_nil
    end
  end
end
