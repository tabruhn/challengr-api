request = require 'supertest'
should = require 'should'
mocha = require 'mocha'

app = require process.cwd() + '/.app'

describe 'UUID', ->
  it 'should return a UUID', (done) ->
    request(app).get('/uuid').expect(200).end((err,res) -> 
      return done(err)if err
      done)
