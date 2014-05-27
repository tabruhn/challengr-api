r = require 'rethinkdb'

exports.setEnvironment = (env) ->
  console.log "set app environment: #{env}"
  switch(env)
    when "development"
      exports.DEBUG_LOG = true
      exports.DEBUG_WARN = true
      exports.DEBUG_ERROR = true
      exports.DEBUG_CLIENT = true

    when "testing"
      exports.DEBUG_LOG = true
      exports.DEBUG_WARN = true
      exports.DEBUG_ERROR = true
      exports.DEBUG_CLIENT = true

    when "production"
      exports.DEBUG_LOG = false
      exports.DEBUG_WARN = false
      exports.DEBUG_ERROR = true
      exports.DEBUG_CLIENT = false
    else
      console.log "environment #{env} not found"

exports.setConfig = (app) ->
  console.log "set configuration"

  exports.MODELS =
    answer:
      item: 'answer'
      table: 'answers'
      whitelist: ['id', 'body', 'questionId']
      sort: ['questionId','id']
    attempt:
      item: 'attempt'
      table: 'attempts'
      whitelist: [ 'id', 'userId', 'challengeId','beganAt', 'finishedAt','tasksAttempted','finalScore' ]
      sort: [ 'id' ]
    category:
      item: 'category'
      table: 'categories'
      whitelist: [ 'id', 'title', 'challenges' ]
      sort: [ 'title' ]
    challenge:
      item: 'challenge'
      table: 'challenges'
      whitelist: [ 'id', 'categoryId', 'taskIds', 'possibleScore','timeLimit','attemptIds' ]
      sort: [ 'categoryId', 'id' ]
    inquiry:
      item: 'inquiry'
      table: 'inquiries'
      whitelist: [ 'id', 'question', 'tagIds']
      sort: [ 'id']
    question:
      item: 'question'
      table: 'questions'
      whitelist: [
        'id'
        'answerIds'
        'roomId'
      ]
      sort: [ 'id' ]
    task:
      item: 'task'
      table: 'tasks'
      whitelist: [ 'id',  'lessonIds' ]
      sort: [ 'id' ]
    user:
      item: 'user'
      table: 'users'
      whitelist: [ 'id', 'name', 'email', 'salt','hash','resetCode','resetExpiresAt','roomIds','memberships','messageIds', 'lessonIds' ]
      sort: [ 'id', 'name']

exports.setDatabase = (app, models) ->
  console.log "set database"

  r.connect { host: 'localhost', port: 28015 }, (err, conn) ->
    throw err if (err)

    for model, options of models
      console.log "running tableCreate for #{model}"

      r.db('challengr').tableCreate(options.table).run conn, (err, res) ->
        if err
          if err.name == "RqlRuntimeError"
            console.log "Table <#{options.table}> already exists. Skipping creation."
          else
            console.log err, res
            throw err
