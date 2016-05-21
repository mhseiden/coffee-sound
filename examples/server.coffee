express = require("express")
app     = express()

app.use(express.static("public"))

server = app.listen 8080, ->
  host = server.address().address
  port = server.address().port
  console.log('static server listening at http://%s:%s', host, port)
