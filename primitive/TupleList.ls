
  do ->

    { value-as-string } = dependency 'native.Value'
    { List, MaybeList, type-error, type-descriptor-as-string, type-name } = dependency 'primitive.Type'
    { string-as-words } = dependency 'native.String'
    { each-item } = dependency 'native.Array'
    { value-as-string } = dependency 'native.Value'
    { Tuple } = dependency 'primitive.Tuple'

    TupleList = (type-descriptor, tuples) ->

      try List tuples
      catch => type-error "Value [#{ type-name tuples }] #{ value-as-string tuples } must be a TupleList"

      type-descriptor = type-descriptor-as-string type-descriptor

      types = type-descriptor |> string-as-words

      each-item tuples, (tuple, index) ->

        try Tuple type-descriptor, tuple
        catch => type-error "Value #{ value-as-string tuple } at index #index of TupleList #{ value-as-string tuples } is not a Tuple <[ #type-descriptor ]>, #{ e.message }"

        tuple

      tuples

    #

    MaybeTupleList = (type-descriptor, value) ->

      try MaybeList value
      catch => type-error "Value #{ value-as-string value } must be either a TupleList or Void"

      TupleList type-descriptor, value \
        unless value is void

      value

    {
      TupleList,
      MaybeTupleList
    }