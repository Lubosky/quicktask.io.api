require 'rails_helper'

RSpec.describe Guest do
  describe '#email' do
    it 'returns nil' do
      guest = Guest.new

      expect(guest.email).to be(nil)
    end
  end

  describe '#confirmed?' do
    it 'returns false' do
      guest = Guest.new

      expect(guest.confirmed?).to be_falsy
    end
  end

  describe '#deactivated?' do
    it 'returns false' do
      guest = Guest.new

      expect(guest.deactivated?).to be_falsy
    end
  end

  describe '#pending?' do
    it 'returns false' do
      guest = Guest.new

      expect(guest.pending?).to be_falsy
    end
  end

  describe '#status' do
    it 'returns false' do
      guest = Guest.new

      expect(guest.status).to eq(:untapped)
    end
  end

  describe '#id' do
    it 'returns nil' do
      guest = Guest.new

      expect(guest.id).to be(nil)
    end
  end

  describe '#uuid' do
    it 'returns nil' do
      guest = Guest.new

      expect(guest.uuid).to be(nil)
    end
  end

  describe '#google_uid' do
    it 'returns nil' do
      guest = Guest.new

      expect(guest.google_uid).to be(nil)
    end
  end

  describe '#password_digest' do
    it 'returns nil' do
      guest = Guest.new

      expect(guest.password_digest).to be(nil)
    end
  end

  describe '#email_confirmed' do
    it 'returns nil' do
      guest = Guest.new

      expect(guest.email_confirmed).to be_falsy
    end
  end

  describe '#workspaces' do
    it 'returns no workspaces' do
      create(:workspace)
      guest = Guest.new

      expect(guest.workspaces).to be_empty
    end
  end
end
