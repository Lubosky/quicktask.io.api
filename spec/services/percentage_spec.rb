require 'rails_helper'

RSpec.describe Percentage do
  let(:value) { 0 }

  subject { Percentage.new(value) }

  describe 'class methods' do
    subject { Percentage }
    it { is_expected.to respond_to(:fractionify) }
  end

  describe '#self.fractionify' do
    let (:subject) { Percentage.fractionify(value) }

    context 'with a numeric value of 50.0' do
      let (:value) { 50.0 }
      it { is_expected.to eql(0.5) }
    end

    context 'with a numeric value of 50' do
      let (:value) { 50 }
      it { is_expected.to eql(0.5) }
    end

    context 'with a decimal number' do
      it 'returns a fraction' do
        expect(Percentage.fractionify(50.011).to_s).to eql('0.50011')
      end

      it 'rounds number to 5 decimal places' do
        expect(Percentage.fractionify(50.011111).to_s).to eql('0.50011')
      end

      it 'rounds rounds half away from zero' do
        expect(Percentage.fractionify(50.0115).to_s).to eql('0.50012')
      end
    end

    context 'with a numeric value of 1' do
      let (:value) { 1 }
      it { is_expected.to eql(0.01) }
    end

    context 'with a numeric value of 0' do
      let (:value) { 0 }
      it { is_expected.to eql(0) }
    end

    context 'with a string value of "50.0"' do
      let (:value) { '50.0' }
      it { is_expected.to eql(0.5) }
    end

    context 'with a string value of "50"' do
      let (:value) { '50' }
      it { is_expected.to eql(0.5) }
    end

    context 'with a string value of "1"' do
      let (:value) { '1' }
      it { is_expected.to eql(0.01) }
    end

    context 'with a string value of "0"' do
      let (:value) { '0' }
      it { is_expected.to eql(0) }
    end

    context 'with a string value of "50.0" and percentage sign "%"' do
      let (:value) { '50.0%' }
      it { is_expected.to eql(0.5) }
    end

    context 'with a comma-separated string value of "50,0"' do
      let (:value) { '50,0' }
      it { is_expected.to eql(0.5) }
    end

    context 'with a comma-separated string value of "50,0" and percentage sign "%"' do
      let (:value) { '50,0%' }
      it { is_expected.to eql(0.5) }
    end
  end
end
