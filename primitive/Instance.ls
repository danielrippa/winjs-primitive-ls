
  do ->

    { Either, Fn, Str, Obj, MaybeFn } = dependency 'primitive.Type'
    { camel-case } = dependency 'native.String'
    { StrList } = dependency 'primitive.StrList'
    { strings-as-function } = dependency 'native.Function'

    new-subscription = (notification-handler) -> Fn notification-handler ; { notification-handler, +enabled }

    new-notification-subscriptions = ->

      self = @

      # last subscription id
      lsi = 0

      next-subscription-id -> lsi += 1 ; "id#lsi"

      subscriptions = {}

      #

      subscribe: (notification-handler) ->

        Fn notification-handler

        subscription-id = next-subscription-id!

        subscriptions[ subscription-id ] = new-subscription notification-handler

        #

        unsubscribe: !-> self.unsubscribe subscription-id
        enable:  !-> subscriptions[ subscription-id ].enabled = yes
        disable: !-> subscriptions[ subscription-id ].enabled = no

      unsubscribe: (subscription-id) -> Str subscription-id ; delete subscriptions[ subscription-id ]

      notify: (notification) !->

        for subscription-id, subscription of subscriptions

          if subscription.enabled

            subscription.notification-handler notification

      #

      camelized = -> [ (camel-case item) for item in it ]

      #

      new-notifier = (names) ->

        StrList names

        do ->

          subscription-names = camelized names

          subscriptions = arrays-as-object subscription-names, [ (new-notification-subscriptions!) for subscription in subscription-names ]

          #

          get-notification-names: -> subscription-names

          bind: (subject) !->

            Obj subject

            for name of subscriptions

              notification-name = camel-case name

              subject[ notification-name ] = eval strings-as-function do

                " handler "
                [ " return subscriptions[ '#notification-name' ].subscribe(handler) " ]

          notify: (names, notification) !->

            StrList names

            for notification-name in camelized names

              subscription = subscriptions[ notification-name ]
              subscription.notify notification

    #

    create-instance = (ancestor = null) -> Either <[ Obj Null ]> ancestor ; Object.create ancestor

    #

    set-property = (instance, property-name, getter, setter) !->

      Obj instance ; Str property-name ; MaybeFn getter ; MaybeFn setter

      descriptor = { +enumerable, +configurable }

      descriptor <<< get: getter \
        if getter isnt void

      descriptor <<< set: setter \
        if setter isnt void

      Object.define-property do

        instance
        camel-case property-name
        descriptor

    #

    new-instance = (members-descriptors, ancestor = null) ->

      Obj members-descriptors ; Either <[ Obj Null ]> ancestor

      instance = create-instance ancestor

      for name, member-descriptor of members-descriptors

        member-type = 'unknown'

        for member-kind, member of member-descriptor

          getter = setter = void

          member-type = match member-type, member-kind

            | 'unknown', 'member' => 'member'
            | 'unknown', 'notifier' => 'notifier'

            | 'unknown', 'getter' => 'read-only'
            | 'unknown', 'setter' => 'write-only'

            | 'write-only', 'getter' => fallthrough
            | 'read-only', 'setter' => 'read-write'

        { getter, setter } = member-descriptor
        notification-types = member

        switch member-type

          | 'read-only' => set-property instance, name, getter
          | 'write-only' => set-property instance, name, void, setter
          | 'read-write' => set-property instance, name, getter, setter

          | 'member' => instance[name] = member

          | 'notifier' =>

            do ->

              notifier = new-notifier notification-types
              notifier.bind instance

              instance[name] = (notification-names, notification) -> names = [ (camelize name) for name in notification-names ] ; notifier.notify names, notification

      instance

    {
      create-instance, set-property,
      new-instance
    }