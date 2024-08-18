
  do ->

    { List: PrimitiveList, type-descriptor-as-string, type-error, isnt-a } = dependency 'primitive.Type'
    { Text } = dependency 'primitive.Text'
    { each-item } = dependency 'native.Array'

    List = (type-descriptor, list) ->

      Text type-descriptor ; PrimitiveList list

      item-type-name = type-descriptor-as-string type-descriptor

      each-item list, (item, index) ->

        type-error "List item #item at index #index is not a #item-type-name" \
          if item `isnt-a` item-type-name

    MaybeList = (type-descriptor, list) ->

      PrimitiveList type-descriptor, list \
        unless list is void

      list

    #

    StrList = -> List <[ Str ]> it

    MaybeStrList = -> MaybeList <[ Str ]> it

    NumList = -> List <[ Num ]> it

    MaybeNumList = -> MaybeList <[ Num ]> it

    BoolList = -> List <[ Bool ]> it

    MaybeBoolList = -> MaybeList <[ Bool ]> it

    FnList = -> List <[ Fn ]> it

    MaybeFnList = -> MaybeList <[ Fn ]> it

    {
      List, MaybeList,
      StrList, MaybeStrList,
      NumList, MaybeNumList,
      BoolList, MaybeBoolList,
      FnList, MaybeFnList
    }