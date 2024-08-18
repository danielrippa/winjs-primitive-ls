
  do ->

    { Obj: PrimitiveObj, MaybeObj: PrimitiveMaybeObj, type-descriptor-as-string, type-name, type-error } = dependency 'primitive.Type'
    { string-as-words, contains-string, array-as-units, array-as-records, array-as-groups } = dependency 'native.String'
    { item-index, contains-item, item-count, drop-last-items, map-items, repeat-item } = dependency 'native.Array'
    { object-keys, object-values } = dependency 'native.Object'

    ellipsis = '...'
    colon = ':'

    Obj = (type-descriptors, obj) ->

      PrimitiveObj obj

      descriptor = type-descriptors = type-descriptor-as-string type-descriptors

      types = type-descriptors |> string-as-words

      type-count = item-count types

      strict = yes

      if types `contains-item` ellipsis

        ellipsis-index = types `item-index` ellipsis

        if ellipsis-index is type-count - 1

          types = drop-last-items types, 1
          type-count = item-count types

          strict = no

        else

          type-error "Invalid Obj type descriptor '#descriptor'. Ellipsis ('...') in Obj type descriptor can only be stated as the last type"

      keys = object-keys obj
      key-count = item-count keys

      if strict

        if key-count isnt type-count

          type-error "Object has #key-count field(s) (#{ keys * ', ' }) while the type descriptor '#descriptor' requires #type-count field(s)."

      for type-descriptor, type-index in types

        unless type-descriptor `contains-string` colon

          type-error "Invalid field type descriptor '#type-descriptor' at index #type-index of Obj type descriptor '#descriptor'. Field type descriptors must be stated as a field type and a field name separated by a colon ('#colon')."

        [ field-type, field-name ] = type-descriptor.split colon

        actual-field-type = type-name obj[field-name]

        if actual-field-type isnt field-type

          type-error "Field '#field-name' of Obj is a #actual-field-type but it must be a #field-type as stated in the Obj type descriptor '#descriptor'."

      obj

    #

    MaybeObj = (type-descriptors, obj) ->

      PrimitiveMaybeObj obj

      if obj isnt void then Obj type-descriptors, obj else obj

    {
      Obj, MaybeObj
    }