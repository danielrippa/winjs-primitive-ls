
  do ->

    { type-name: native-type-name, native-type: n } = dependency 'native.Type'
    { array-as-object } = dependency 'native.Array'
    { trim, lower-case } = dependency 'native.String'

    p = primitive-type = array-as-object <[ Str Null Obj Num NaN List Bool Fn Void Tuple ]>

    type-name = (value) ->

      switch native-type-name value

        | n.String => p.Str
        | n.Object, n.Error =>

          switch value
            | null => p.Null
            | undefined => p.Void
            else p.Obj

        | n.Number =>

          switch value
            | value => p.Num
            else p.NaN

        | n.Array, n.Arguments => p.List
        | n.Boolean => p.Bool
        | n.Function => p.Fn
        | n.Undefined => p.Void

        else that

    #

    type-error = (message) -> throw new Error "TypeError: #message"

    type-descriptor-as-string = (descriptor) ->

      switch type-name descriptor

        | p.List => descriptor * ' '
        | p.Str => descriptor

        else type-error "Invalid type descriptor '#descriptor'. It muse be any of Str, List."

    fails-to-be = (value, message) !-> type-error "Value [#{ type-name value }] #{ String value } must be #message"

    #

    sanitized = -> it |> trim |> lower-case

    is-a = (value, required-type-name) ->

      required-type-name `fails-to-be` p.Str \
        if (sanitized type-name required-type-name) isnt (sanitized p.Str)

      required-type-name = sanitized required-type-name
      value-type-name = sanitized type-name value

      value-type-name is required-type-name

    isnt-a = (value, required-type-name) -> not (value `is-a` required-type-name)

    #

    Type = (type-descriptor, value) ->

      required-type-name = type-descriptor |> type-descriptor-as-string

      value `fails-to-be` required-type-name \
        unless value `is-a` required-type-name

      value

    #

    Either = (types-descriptor, value) ->

      types-descriptor = types-descriptor |> type-descriptor-as-string

      types = types-descriptor / ' '

      actual-type = void
      value-type = type-name value

      for type in types

        if type is value-type
          actual-type = type
          break

      value `fails-to-be` "any of #{ types * ', ' }" \
        if actual-type is void

      value

    #

    Maybe = (type-descriptor, value) -> Either [ type-descriptor, p.Void ], value

    #

    Str = -> Type <[ Str ]> it
    MaybeStr = -> Maybe <[ Str ]> it

    Obj = -> Type <[ Obj ]> it
    MaybeObj = -> Maybe <[ Obj ]> it

    Num = -> Type <[ Num ]> it
    MaybeNum = -> Maybe <[ Num ]> it

    List = -> Type <[ List ]> it
    MaybeList = -> Maybe <[ List ]> it

    Bool = -> Type <[ Bool ]> it
    MaybeBool = -> Maybe <[ Bool ]> it

    Fn = -> Type <[ Fn ]> it
    MaybeFn = -> Maybe <[ Fn ]> it

    {
      primitive-type,
      type-name,
      type-descriptor-as-string, type-error,
      Type, Either, Maybe,
      Str, MaybeStr, Num, MaybeNum, Bool, MaybeBool, Fn, MaybeFn,
      Obj, MaybeObj, List, MaybeList,
      is-a, isnt-a
    }