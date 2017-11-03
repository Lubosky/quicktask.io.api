require 'rails_helper'

RSpec.describe Coupon, type: :model do
  before {
    StripeMock.start
    stub_stripe_coupons
  }

  after { StripeMock.stop }

  it 'has a code of the given stripe coupon code' do
    coupon = Coupon.new('5OFF')
    expect(coupon.code).to eq '5OFF'
  end

  it 'uses the corresponding stripe coupon' do
    coupon = Coupon.new('5OFF')

    expect(coupon.stripe_coupon.id).to eq coupon.code
  end

  it 'delegates duration to stripe_coupon' do
    coupon = Coupon.new('5OFF')

    expect(coupon.duration).to eq 'once'
  end

  it 'delegates duration_in_months to stripe_coupon' do
    coupon = Coupon.new('25OFF')

    expect(coupon.duration_in_months).to eq(3)
  end

  describe '#valid?' do
    it 'is valid if the coupon exists and is usable' do
      coupon = Coupon.new('5OFF')

      expect(coupon).to be_valid
    end

    it 'is not valid if the coupon code does not exist' do
      coupon = Coupon.new('NONE')

      expect(coupon).not_to be_valid
    end

    it 'is not valid if it can\'t be used' do
      coupon = Coupon.new('50OFF')

      expect(coupon).not_to be_valid
    end
  end

  describe '#apply' do
    context 'when it is an amount off discount' do
      it 'deducts that dollar amount' do
        coupon = Coupon.new('5OFF')

        amount = coupon.apply(10)

        expect(amount).to eq 5
      end
    end

    context 'when it is a percentage off discount' do
      it 'deducts that percentage off the amount' do
        coupon = Coupon.new('25OFF')

        amount = coupon.apply(100)

        expect(amount).to eq 75.00
      end
    end
  end
end
