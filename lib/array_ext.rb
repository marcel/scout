class Array
  def percentile(percent)
    percentile_index = (size * (percent / 100.0)).floor
    sort[[percentile_index, size - 1].min]
  end
end