
  do ->

    { type-error, Num } = dependency 'primitive.Type'

    NumRange = (min, max, value) ->

      Num min ; Num max ; Num value

      type-error "Min value '#min' in NumRange must be lower than Max value '#max'." \
        unless max > min

      type-error "Value '#value' out of range (min: #min, max: #max)." \
        unless value >= min and value <= max

      value

    {
      NumRange
    }

