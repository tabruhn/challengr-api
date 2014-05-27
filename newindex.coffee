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
    attempt:
      item: 'attempt'
      table: 'attempts'
      whitelist: [ 'id', 'userId', 'challengeId','beganAt', 'finishedAt','tasksAttempted','finalScore' ]
      sort: [ 'id' ]
    category:
      item: 'category'
      table: 'categories'
      whitelist: [ 'id', 'title', 'challenges' ]
      sort: [ 'name' ]
    challenge:
      item: 'challenge'
      table: 'challenges'
      whitelist: [ 'id', '', 'definition', 'lessonIds' ]
      sort: [ 'word' ]
    inquiry:
      item: 'inquiry'
      table: 'inquiries'
      whitelist: [ 'id', 'filename', 'type', 'lessonIds' ]
      sort: [ 'type', 'filename' ]
    question:
      item: 'question'
      table: 'questions'
      whitelist: [
        'id'
        'title'
        'introduction'
        'justification'
        'content'
        'timeToComplete'
        'authorId'
        'categoryId'
        'objectiveId'
        'annotationIds'
        'assessmentIds'
        'attachmentIds'
        'figureIds'
        'glossaryIds'
        'prerequisiteIds'
        'referenceIds'
        'resourceIds'
        'syllabusIds'
        'tagIds'
      ]
      sort: [ 'title' ]
    task:
      item: 'task'
      table: 'tasks'
      whitelist: [ 'id', 'idea', 'lessonIds' ]
      sort: [ 'idea' ]
    user:
      item: 'user'
      table: 'users'
      whitelist: [ 'id', 'name', 'email', 'lessonIds' ]
      sort: [ 'name' ]

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
