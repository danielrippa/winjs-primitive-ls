
  do ->

    { List } = dependency 'primitive.Type'
    { Obj, obj-as-units, obj-as-output-metadata } = dependency 'primitive.Obj'
    { object-keys } = dependency 'native.Object'
    { each-item, map-items, item-count, first-item, repeat-item } = dependency 'native.Array'
    { array-as-units, array-as-records, array-as-groups } = dependency 'native.String'

    ObjList = (type-descriptor, list) ->

      List list

      each-item list, (obj) -> Obj type-descriptor, obj

      list

    MaybeObjList = (type-descriptor, list) ->

      ObjList type-descriptor, list \
        unless list is void

      list

    obj-list-as-records = (obj-list, type-descriptor = '...') ->

      ObjList type-descriptor, obj-list

      map-items obj-list, obj-as-units

      obj-list |> map-items _ , obj-as-units |> array-as-records

    obj-list-as-output = (obj-list, type-descriptor = '...') ->

      switch item-count obj-list

        | 0 => [ '', '' ] |> array-as-groups

        else

          metadata-records = obj-list |> first-item |> obj-as-output-metadata _ , type-descriptor

          data-records = obj-list-as-records obj-list, type-descriptor

          [ metadata-records, data-records ] |> array-as-groups

    {
      ObjList, MaybeObjList,
      obj-list-as-records, obj-list-as-output
    }