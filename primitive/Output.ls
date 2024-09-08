
  do ->

    { arrays-as-output, new-column-metadata } = dependency 'native.Output'
    { Obj } = dependency 'primitive.Obj'
    { type-descriptor-as-string, type-name, Either, primitive-type: p } = dependency 'primitive.Type'
    { object-keys, object-values } = dependency 'native.Object'
    { array-as-units, groups-as-array, records-as-array, units-as-array } = dependency 'native.String'
    { item-count, map-items, repeat-item, first-item } = dependency 'native.Array'
    { ObjList } = dependency 'primitive.ObjList'
    { MaybeText } = dependency 'primitive.Text'
    { Tuple } = dependency 'primitive.Tuple'
    { TupleList } = dependency 'primitive.TupleList'

    repeat-as-units = (value, n) -> value |> repeat-item _ , n |> array-as-units

    obj-metadata = (obj) -> [ ( new-column-metadata field-name, type-name obj[field-name] ) for field-name of obj ]

    obj-as-output = (obj, type-descriptor = '...') ->

      MaybeText type-descriptor ; type-descriptor = type-descriptor-as-string type-descriptor ; Obj type-descriptor, obj

      arrays-as-output [ object-values obj ], obj-metadata obj

    #

    obj-list-as-output = (obj-list, type-descriptor = '...') ->

      MaybeText type-descriptor ; type-descriptor = type-descriptor-as-string type-descriptor ; ObjList type-descriptor, obj-list

      if (item-count obj-list) is 0

        arrays-as-output [ [ '' ] ]

      else

        arrays = map-items obj-list, object-values
        metadata = obj-metadata first-item obj-list

        arrays-as-output arrays, metadata

    tuple-as-obj = (tuple) -> { [ "Element#index", value ] for value, index in tuple }

    tuple-as-output = (tuple, type-descriptor = '...') ->

      MaybeText type-descriptor ; type-descriptor = type-descriptor-as-string type-descriptor ; Tuple type-descriptor, tuple

      obj-as-output tuple-as-obj tuple, type-descriptor

    tuple-list-as-output = (tuple-list, type-descriptor = '...') ->

      MaybeText type-descriptor ; type-descriptor = type-descriptor-as-string type-descriptor ; TupleList type-descriptor, tuple-list

      obj-list-as-output (map-items tuple-list, tuple-as-obj), type-descriptor

    #

    # units-as-items = (units) -> units |> units-as-array |> map-items units, entity-decode

    typed-value = (type, value) ->

      switch type

        | p.Num => Number value

        else value

    parse-output = (output) ->

      [ metadata-records, data-records ] = groups-as-array output

      metadata = metadata-records |> records-as-array
      data =     data-records     |> records-as-array

      [ name-units, type-units, width-units, style-units ] = metadata

      names = name-units |> units-as-array
      types = type-units |> units-as-array
      widths = width-units |> units-as-array
      styles = style-units |> units-as-array

      rows = data |> map-items _ , units-as-array

      objects = []

      for row in rows

        object = {}

        for value, index in row

          name = names[index]
          type = types[index]

          object[ name ] = typed-value type, value

        objects.push object

      { objects, names, types, widths, styles }

    {
      obj-as-output, obj-list-as-output,
      tuple-as-output, tuple-list-as-output,
      parse-output
    }