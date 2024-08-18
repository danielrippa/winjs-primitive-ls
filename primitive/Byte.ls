
  do ->

    { NumRange } = dependency 'primitive.NumRange'

    Byte = (value) -> NumRange 0, 255, value

    {
      Byte
    }