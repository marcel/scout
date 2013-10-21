class DropdownMenu
  attr_reader :options
  attr_writer :label

  def initialize(&block)
    @options = []
    instance_eval(&block) if block_given?
  end

  def label(value = nil)
    value ? @label = value : @label
  end

  def option(&block)
    options << Option.new(&block)
  end

  def has_current_value?(params)
    !current_value(params).nil?
  end

  def button_type(params)
    has_current_value?(params) ? 'btn-info' : ''
  end

  def current_value(params)
    options.find do |option|
      params.has_key?(option.parameter) &&
        params[option.parameter] == option.value.to_s
    end.try(:label)
  end

  def reset_values
    @reset_values ||= options.inject({}) do |null_values, option|
      null_values[option.parameter] = nil
      null_values
    end
  end

  def divider!
    options.last.add_divider = true
  end

  class Option
    attr_writer :label, :add_divider

    def add_divider?
      @add_divider == true
    end

    def initialize(&block)
      instance_eval(&block) if block_given?
    end

    def label(value = nil)
      value ? @label = value : @label
    end

    def parameter(value = nil)
      value ? @parameter = value : @parameter
    end

    def value(v = nil)
      v ? @value = v.to_s : (@value || @label)
    end

    def parameters
      {parameter => value}
    end
  end
end