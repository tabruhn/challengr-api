r    = require 'rethinkdb'
_    = require 'underscore'
crud = require './crud'

module.exports = (app, model) ->

  findAll  = (req, res) -> crud.findAll  req, res, model
  findById = (req, res) -> crud.findById req, res, model
  upsert   = (req, res) -> crud.upsert   req, res, model
  update   = (req, res) -> crud.update   req, res, model
  destroy  = (req, res) -> crud.destroy  req, res, model

  app.get    "/#{model.table}",     findAll
  app.get    "/#{model.table}/:id", findById
  app.put    "/#{model.table}/:id", upsert
  app.patch  "/#{model.table}/:id", update
  app.delete "/#{model.table}/:id", destroy
