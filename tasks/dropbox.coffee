request = require 'request'

req = request.defaults
  json: true
  uri: 'https://content.dropboxapi.com/2/files/download'

token = 'Bearer 5LTVvc5TbysAAAAAAAAAESnWQj7UXc7aRyojSnPzRbM6BDcCQaY05wCYlWwKlGGC'
# uri = 'https://www.dropbox.com/s/pqhexe8kggpm57k/artwork.csv?dl=1'

### coffee tasks/dropbox.coffee ###
payload =
  headers:
    'Authorization': token
    'Dropbox-API-Arg': { "path": "/artwork.csv" }

# payload.headers['Dropbox-API-Arg'] = # "{\"path\":\"\/Apps\/ee-admin\/artwork.csv\"}"
#   path: "Apps/ee-admin/artwork.csv"

# {"path":"/Apps/ee-admin/artwork.csv"}

console.log payload

req.post payload, (err, res, body) ->
  if !err and res.statusCode is 200
    csv = body
    console.log csv
    process.exit()
  else
    console.log 'err', err
    console.log 'body', body
