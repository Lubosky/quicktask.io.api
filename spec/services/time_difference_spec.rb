require 'rails_helper'

RSpec.describe TimeDifference do
  def self.with_each_class(&block)
    classes = [Time, Date, DateTime]

    classes.each do |klass|
      context "with a #{klass.name} class" do
        instance_exec klass, &block
      end
    end
  end

  describe '.between' do
    with_each_class do |klass|
      it 'returns a new TimeDifference instance in each unit' do
        start_time = klass.new(2018, 1)
        end_time = klass.new(2018, 12)

        expect(TimeDifference.between(start_time, end_time)).to be_a(TimeDifference)
      end
    end
  end

  describe '#in_years' do
    with_each_class do |klass|
      it 'returns time difference in years based on Wolfram Alpha' do
        start_time = klass.new(2018, 1)
        end_time = klass.new(2018, 12)

        expect(TimeDifference.between(start_time, end_time).in_years).to eql(0.91)
      end

      it 'returns an negative difference' do
        start_time = klass.new(2018, 12)
        end_time = klass.new(2018, 1)

        expect(TimeDifference.between(start_time, end_time).in_years).to eql(-0.91)
      end
    end
  end

  describe '#in_months' do
    with_each_class do |klass|
      it 'returns time difference in months based on Wolfram Alpha' do
        start_time = klass.new(2018, 1)
        end_time = klass.new(2018, 12)

        expect(TimeDifference.between(start_time, end_time).in_months).to eql(10.98)
      end

      it 'returns an negative difference' do
        start_time = klass.new(2018, 12)
        end_time = klass.new(2018, 1)

        expect(TimeDifference.between(start_time, end_time).in_months).to eql(-10.98)
      end
    end
  end

  describe '#in_weeks' do
    with_each_class do |klass|
      it 'returns time difference in weeks based on Wolfram Alpha' do
        start_time = klass.new(2018, 1)
        end_time = klass.new(2018, 12)

        expect(TimeDifference.between(start_time, end_time).in_weeks).to eql(47.71)
      end

      it 'returns an negative difference' do
        start_time = klass.new(2018, 12)
        end_time = klass.new(2018, 1)

        expect(TimeDifference.between(start_time, end_time).in_weeks).to eql(-47.71)
      end
    end
  end

  describe '#in_days' do
    with_each_class do |klass|
      it 'returns time difference in weeks based on Wolfram Alpha' do
        start_time = klass.new(2018, 1)
        end_time = klass.new(2018, 12)

        expect(TimeDifference.between(start_time, end_time).in_days).to eql(334.0)
      end

      it 'returns an negative difference' do
        start_time = klass.new(2018, 12)
        end_time = klass.new(2018, 1)

        expect(TimeDifference.between(start_time, end_time).in_days).to eql(-334.0)
      end
    end
  end

  describe '#in_hours' do
    with_each_class do |klass|
      it 'returns time difference in hours based on Wolfram Alpha' do
        start_time = klass.new(2018, 1)
        end_time = klass.new(2018, 12)

        expect(TimeDifference.between(start_time, end_time).in_hours).to eql(8016.0)
      end

      it 'returns an negative difference' do
        start_time = klass.new(2018, 12)
        end_time = klass.new(2018, 1)

        expect(TimeDifference.between(start_time, end_time).in_hours).to eql(-8016.0)
      end
    end
  end

  describe '#in_minutes' do
    with_each_class do |klass|
      it 'returns time difference in minutes based on Wolfram Alpha' do
        start_time = klass.new(2018, 1)
        end_time = klass.new(2018, 12)

        expect(TimeDifference.between(start_time, end_time).in_minutes).to eql(480960.0)
      end

      it 'returns an negative difference' do
        start_time = klass.new(2018, 12)
        end_time = klass.new(2018, 1)

        expect(TimeDifference.between(start_time, end_time).in_minutes).to eql(-480960.0)
      end
    end
  end

  describe '#in_seconds' do
    with_each_class do |klass|
      it 'returns time difference in seconds based on Wolfram Alpha' do
        start_time = klass.new(2018, 1)
        end_time = klass.new(2018, 12)

        expect(TimeDifference.between(start_time, end_time).in_seconds).to eql(28857600.0)
      end

      it 'returns an negative difference' do
        start_time = klass.new(2018, 12)
        end_time = klass.new(2018, 1)

        expect(TimeDifference.between(start_time, end_time).in_seconds).to eql(-28857600.0)
      end
    end
  end
end
