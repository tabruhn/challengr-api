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
    annotation:
      item: 'annotation'
      table: 'annotations'
      whitelist: [ 'id', 'markdown', 'lessonIds' ]
      sort: [ 'id' ]
    assessment:
      item: 'assessment'
      table: 'assessments'
      whitelist: [ 'id', 'content', 'lessonIds' ]
      sort: [ 'id' ]
    attachment:
      item: 'attachment'
      table: 'attachment'
      whitelist: [ 'id', 'filename', 'type', 'lessonIds' ]
      sort: [ 'type', 'filename' ]
    category:
      item: 'category'
      table: 'categories'
      whitelist: [ 'id', 'name', 'lessonIds' ]
      sort: [ 'name' ]
    entry:
      item: 'entry'
      table: 'entries'
      whitelist: [ 'id', 'word', 'definition', 'lessonIds' ]
      sort: [ 'word' ]
    figure:
      item: 'figure'
      table: 'figures'
      whitelist: [ 'id', 'filename', 'type', 'lessonIds' ]
      sort: [ 'type', 'filename' ]
    lesson:
      item: 'lesson'
      table: 'lessons'
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
    objective:
      item: 'objective'
      table: 'objectives'
      whitelist: [ 'id', 'idea', 'lessonIds' ]
      sort: [ 'idea' ]
    reference:
      item: 'reference'
      table: 'references'
      whitelist: [ 'id', 'url', 'type', 'lessonIds' ]
      sort: [ 'type', 'url' ]
    syllabus:
      item: 'syllabus'
      table: 'syllabi'
      whitelist: [ 'id', 'title', 'lessonIds' ]
      sort: [ 'title' ]
    tag:
      item: 'tag'
      table: 'tags'
      whitelist: [ 'id', 'name', 'lessonIds' ]
      sort: [ 'name' ]
    user:
      item: 'user'
      table: 'users'
      whitelist: [ 'id', 'name', 'email', 'lessonIds' ]
      sort: [ 'name' ]
    curriculum:
      item: 'curriculum'
      table: 'curricula'
      whitelist: [ 'id', 'title', 'lessonIds' ]
      sort: [ 'title' ]


exports.setDatabase = (app, models) ->
  console.log "set database"

  r.connect { host: 'localhost', port: 28015 }, (err, conn) ->
    throw err if (err)

    for model, options of models
      console.log "running tableCreate for #{model}"

      r.db('davinci').tableCreate(options.table).run conn, (err, res) ->
        if err
          if err.name == "RqlRuntimeError"
            console.log "Table <#{options.table}> already exists. Skipping creation."
          else
            console.log err, res
            throw err
