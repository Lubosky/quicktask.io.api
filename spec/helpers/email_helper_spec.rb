require 'rails_helper'

RSpec.describe EmailHelper, type: :helper do
  describe 'formatted_time_relative_to_age' do
    let(:time) { Time.parse '2017-01-02 16:55:00 UTC' }

    subject do
      helper.formatted_time_relative_to_age(time)
    end

    context 'when time is same day' do
      it 'displays hours, minutes and meridian' do
        Timecop.freeze('2017-01-02 12:00:00 UTC') do
          expect(subject).to eq ' 4:55 pm'
        end
      end
    end

    context 'when it is not the same day' do
      it 'displays date only' do
        Timecop.freeze('2017-01-01 12:00:00 UTC') do
          expect(subject).to eq ' 2 Jan'
        end
      end
    end

    context 'when it is not the same year' do
      it 'displays date and year' do
        Timecop.freeze('2018-01-01 12:00:00 UTC') do
          expect(subject).to eq '2/1/17'
        end
      end
    end
  end
end
