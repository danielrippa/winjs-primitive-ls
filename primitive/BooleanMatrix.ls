
  do ->

    { Num } = dependency 'primitive.Type'

    new-boolean-matrix = (rows, columns) ->

      Num rows ; Num columns

      cells = [ [ (off) for column to columns ] for row to rows ]

      get: (x, y) ->

        row = cells[x]
        return if row is void

        cells[x][y]

      set: (x, y, value = on) !->

        return if x >= (cells.length - 1)
        return if y >= (cells.0.length - 1)

        cells[x][y] := value

      unset: (x, y) !-> @set x, y, off

    {
      new-boolean-matrix
    }
