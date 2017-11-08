express = require 'express'
request = require 'request-promise-native'
_ = require 'underscore'

app = express()
app.use express.static 'web'

fsqRequest = (endpoint) ->
  request
    url: 'https://api.foursquare.com/v2/' + endpoint
    qs:
      client_id: process.env.FOURSQUARE_CLIENT_ID
      client_secret: process.env.FOURSQUARE_CLIENT_SECRET
      v: '20171101'
      limit: 1000

compareSaved = (selfUserid, otherUserid) ->
  $.when getSaved(latlng, selfUserid), getSaved(latlng, otherUserid)
    .then (selfResults, otherResults) ->
      console.log _.filter parseSaved(selfResults), (value) ->
        _.contains _.pluck(parseSaved(otherResults), 'id'), value.id

parseSaved = (data) ->
  _.map data.response.list.listItems.items, (value) ->
    value.venue

app.get '/venues/liked/:userid/with/:otheruserid', (req, res) ->
  Promise.all [fsqRequest('lists/' + req.params.userid + '/venuelikes'), fsqRequest('lists/' + req.params.otheruserid + '/venuelikes')]
    .then (data) =>
      res.json _.filter parseSaved(JSON.parse data[0]), (value) ->
        _.contains _.pluck(parseSaved(JSON.parse data[1]), 'id'), value.id

app.get '/venues/saved/:userid/with/:otheruserid', (req, res) ->
  Promise.all [fsqRequest('lists/' + req.params.userid + '/todos'), fsqRequest('lists/' + req.params.otheruserid + '/todos')]
    .then (data) =>
      res.json _.filter parseSaved(JSON.parse data[0]), (value) ->
        _.contains _.pluck(parseSaved(JSON.parse data[1]), 'id'), value.id

app.use (req, res) ->
  res.sendStatus 404

app.listen process.env.PORT or 8080
