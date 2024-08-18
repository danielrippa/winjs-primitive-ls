
  do ->

    # Text has a dual nature. It can be either a Str or a StrList.
    # If can contain various separators, most commonly crlf, lf, etc.
    # Conceptually text, either as a StrList or as a Str containing separators, represents a List of Str
    # where each Str represents a line of text.

    { Either, type-name, primitive-type: p, Str, List } = dependency 'primitive.Type'
    { control-chars, string-as-records, records-as-array } = dependency 'native.String'

    Text = -> Either <[ Str List ]> it
    MaybeText = -> Either <[ Str List Void ]> it

    #

    { lf } = control-chars

    text-as-string = (text, separator = lf) ->

      Text text ; Str separator

      if (type-name text) is p.List
        text.join separator
      else
        text

    #

    text-as-lines = (text) -> text |> text-as-string |> string-as-records |> records-as-array

    lines-as-string = (lines, separator = lf) -> List lines |> array-as-records |> records-as-string _ , separator

    {
      Text, MaybeText,
      text-as-string, text-as-lines, lines-as-string
    }
