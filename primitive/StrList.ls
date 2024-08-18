
  do ->

    { List, Str } = dependency 'primitive.Type'
    { each-item } = dependency 'native.Array'

    StrList = (list) -> each-item (List list), Str

    MaybeStrList = (list) ->

      StrList list \
        unless list is void

      list

    {
      StrList, MaybeStrList
    }