r = require 'rethinkdb'
_ = require 'underscore'

exports.findAll = (req, res, model) ->
  try
    r.connect { host: 'localhost', port: 28015 }, (err, conn) ->
      throw err if err?

      query = r.db('challengr').
        table( model.table ).
        orderBy( getSortOrder(req.query, model)... ).
        pluck( getFields(req.query, model) ).
        slice( getRange(req)... )

      query.run conn, (err, cursor) ->
        if err?
          res.send 500
          return

        cursor.toArray (err, result) ->
          if err?
            res.send 500
            return

          out = {}
          out[model.table] = _.map result, (item) ->
            _.extend _.pick( item, model.whitelist ),
              href: "http://localhost:3000/#{item.id}"
          res.json out

  catch error
    console.log "error", error
    res.send 500
  finally
    conn.close() if conn?

exports.findById = (req, res, model) ->
  try
    r.connect { host: 'localhost', port: 28015 }, (err, conn) ->
      throw err if err?

      query = r.db('challengr').
        table(model.table).
        get(req.params.id).
        pluck getFields(req.query, model)

      query.run conn, (err, result) ->

        if !result?
          res.send 404
        else
          out = {}
          out[model.table] = [ _.pick result, model.whitelist ]
          res.json out

  catch error
    console.log "error", error
    res.send 500
  finally
    conn.close() if conn?

# put
exports.upsert = (req, res, model) ->
  try
    r.connect { host: 'localhost', port: 28015 }, (err, conn) ->
      throw err if err?

      json = req.body[model.item]
      json = _.pick _.extend(json, id: req.params.id), model.whitelist

      query = r.db('challengr').
        table(model.table).
        insert json, upsert: true

      try
        query.run conn, (err, result) ->
          throw err if err?

          console.log "upsert", result

          out = {}
          out[model.table] = [ json ]

          switch
            when result.replaced > 0
              res.json 200, out

            when result.inserted > 0
              res.location "/#{model.table}/#{req.params.id}"
              res.json 201, out

            when result.unchanged > 0
              res.send 204

            else
              res.send 400

      catch error
        res.json 422, error: error
      finally
        conn.close() if conn?

  catch error
    console.log "error", error
    res.send 500
  finally
    conn.close() if conn?

# patch
exports.update = (req, res, model) ->
  try
    r.connect { host: 'localhost', port: 28015 }, (err, conn) ->
      throw err if err?

      json = _.pick req.body[model.item], model.whitelist

      try
        query = r.db('challengr').
          table(model.table).
          get(req.params.id).
          update(json)

        query.run conn, (err, result) ->
          throw err if err?
          res.send 204

      catch error
        res.json 422, error: error
      finally
        conn.close() if conn?

  catch error
    console.log "error", error
    res.send 500
  finally
    conn.close() if conn?

exports.destroy = (req, res, model) ->
  try
    r.connect { host: 'localhost', port: 28015 }, (err, conn) ->
      throw err if err?

      query = r.db('challengr').
        table(model.table).
        get(req.params.id).
        delete()

      query.run conn, (err, result) ->
        throw err if err?

        if result.skipped > 0
          res.send 404
        else
          res.send 204

  catch error
    console.log 'error', err
    res.send 500
  finally
    conn.close() if conn?

getFields = (query, model) ->
  fields = if query.fields?
    if _.has(query.fields, model.table)
      query.fields[model.table].split ','
    else
      query.fields.split ','

  if fields?
    _.intersection(fields, model.whitelist)
  else
    model.whitelist

setSortDirection = (field) ->
  if field[0] == "-"
    r.desc(field)
  else
    r.asc(field)

getSortOrder = (query, model) ->
  if query.sort?
    _.map query.sort.split(','), (field) ->
      setSortDirection(field)
  else
    setSortDirection(field) for field in model.sort

getRange = (req) ->
  header = req.get('range')

  try
    header = header.split("=")[1].split("-")
    parseInt(num) for num in [ header[0] - 1, header[1] ]
  catch
    [0,99]
