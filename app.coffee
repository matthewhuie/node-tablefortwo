express = require 'express'
request = require 'request'

app = express()
app.use express.static 'web'

app.use (req, res) ->
  res.sendStatus 404

app.listen process.env.PORT or 8080
