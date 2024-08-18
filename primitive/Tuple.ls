
  do ->

    { List, MaybeList, type-descriptor-as-string, type-name, type-error } = dependency 'primitive.Type'
    { string-as-words, parens, drop-last-chars, drop-first-chars } = dependency 'native.String'
    { item-count, last-item, item-index, contains-item, drop-first-items, drop-last-items } = dependency 'native.Array'
    { value-as-string } = dependency 'native.Value'

    ellipsis = '...'
    question-mark = '?'

    Tuple = (types-descriptor, elements) ->

      try List elements
      catch => type-error "Value #{ value-as-string elements } must be a Tuple"

      element-count = item-count elements

      types-descriptor = types-descriptor |> type-descriptor-as-string

      types = types-descriptor |> string-as-words ; type-count = item-count types

      strict = yes

      ellipsis-index = types `item-index` ellipsis

      if types `contains-item` ellipsis

        switch ellipsis-index

          | type-count - 1 => strict = no

          else type-error "Invalid Tuple type descriptor '#types-descriptor'. The ellipsis (#ellipsis) can only be stated at the end of the type descriptor"

      if not strict

        types = drop-last-items types, 1
        type-count = item-count types

      else

        if element-count isnt type-count

          type-error "Tuple #{ tuple-as-string elements } contains #element-count elements while the descriptor '#types-descriptor' defines #type-count elements."

      for type, index in types

        continue if type is '?'

        element = elements[index]

        element-type = type-name element

        if element-type isnt type

          type-error "Tuple element '#{ value-as-string element }' at tuple index #index of tuple #{ tuple-as-string elements } must be a #type as stated by the Tuple type descriptor '#types-descriptor'"

      elements

    #

    MaybeTuple = (types-descriptor, elements) ->

      try MaybeList elements
      catch => type-error "Value #{ elements } must be either a Tuple or Void"

      Tuple elements \
        if elements isnt void

      elements

    tuple-as-string = (tuple, types-descriptor = '...') ->

      Tuple types-descriptor, tuple

      as-string = tuple |> value-as-string |> drop-first-chars _ , 1 |> drop-last-chars _ , 1 |> parens

    {
      Tuple, MaybeTuple
      tuple-as-string
    }
