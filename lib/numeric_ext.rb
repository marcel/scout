class Numeric
  def percent_of(other_number)
    (to_f / other_number * 100).round(2)
  end
end