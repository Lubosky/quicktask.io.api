class TimeDifference
  private_class_method :new

  TIME_COMPONENTS = [:years, :months, :weeks, :days, :hours, :minutes, :seconds]

  def self.between(start_time, end_time)
    new(start_time, end_time)
  end

  def in_years
    in_unit(:years)
  end

  def in_months
    (@time_difference / (1.day * 30.42)).round(2)
  end

  def in_weeks
    in_unit(:weeks)
  end

  def in_days
    in_unit(:days)
  end

  def in_hours
    in_unit(:hours)
  end

  def in_minutes
    in_unit(:minutes)
  end

  def in_seconds
    @time_difference
  end

  private

  def initialize(start_time, end_time)
    start_time = time_in_seconds(start_time)
    end_time = time_in_seconds(end_time)

    @time_difference = (end_time - start_time)
  end

  def time_in_seconds(time)
    time.to_time.to_f
  end

  def in_unit(unit)
    (@time_difference / 1.send(unit)).round(2)
  end
end
