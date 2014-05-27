express      = require 'express'
rethinkdb    = require 'rethinkdb'
session      = require 'express-session'
cookieParser = require 'cookie-parser'
bodyParser   = require 'body-parser'
logger       = require 'morgan'
uuid         = require 'node-uuid'
_            = require 'underscore'

app = express()

logger format: 'dev', immediate: true

app.port = process.env.PORT or process.env.VMC_APP_PORT or 3001
env = process.env.NODE_ENV or "development"

config = require "./config"
config.setEnvironment env
config.setConfig app
config.setDatabase app, config.MODELS

app.use express.static(process.cwd() + '/public')

console.log "setting session/cookie"
app.use cookieParser()
app.use session(
  secret: "unthinkable maury brown"
  key: "sid"
  cookie:
    secure: true
)

app.use bodyParser.json()
app.use bodyParser.urlencoded()
app.use logger('dev')

# Initialize routes
routes = require './modules/routes'
routes(app, model) for name, model of config.MODELS

# Supply server-side UUIDs
app.get '/uuid/:count', (req, res) ->
  try
    count = parseInt req.params.count
    uuids = ( uuid.v4() for number in [1..count] )
    res.json uuids: uuids
  catch error
    console.log "ERROR!!!!", error
    res.send uuid.v4()
app.get '/uuid', (req, res) -> res.send uuid.v4()

# Root page
app.get '/', (req, res) ->
  links = {}
  port = if app.port == 80 then "" else ":#{app.port}"
  for name, model of config.MODELS
    links[model.table] = "http://#{req.host}#{port}/#{model.table}"
  res.json links

# Export application object
module.exports = app
