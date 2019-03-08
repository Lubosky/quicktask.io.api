class Percentage < Numeric
  ZERO = 0.0
  ONE_HUNDRED = 100

  def self.fractionify(val = 0)
    new(val).fractionify
  end

  def initialize(val = 0)
    val = ZERO                if !val
    val = ONE_HUNDRED         if val == true
    val = val.tr!(',', '.')   if val.is_a?(String) && val[',']
    val = val.to_r            if val.is_a?(String) && val['/']
    val = val.to_f            if val.is_a?(Complex) || val.is_a?(Rational)
    val = val.to_i            if val.is_a?(String) && !val['.']
    val = val.to_d / ONE_HUNDRED

    @value = val.to_d
  end

  def fractionify
    begin
      BigDecimal(@value.to_s).round(5, BigDecimal::ROUND_HALF_UP)
    rescue
      ZERO
    end
  end
end
