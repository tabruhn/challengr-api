request = require 'supertest'

app = require process.cwd() + '/.app'

describe 'UUID', ->
  it "should return a UUID", (done) ->
    request(app).get("/uuid").expect(200, "", done)
