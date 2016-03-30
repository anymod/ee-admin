request   = require 'request'
parse     = require 'csv-parse'
_         = require 'lodash'
Promise   = require 'bluebird'
argv      = require('yargs').argv
sequelize = require '../config/sequelize/setup'

mappings  = require './doba.mappings'

token       = 'Bearer 5LTVvc5TbysAAAAAAAAAESnWQj7UXc7aRyojSnPzRbM6BDcCQaY05wCYlWwKlGGC'
api_uri     = 'https://api.dropboxapi.com/2'
content_uri = 'https://content.dropboxapi.com/2'

# uri = 'https://www.dropbox.com/s/pqhexe8kggpm57k/artwork.csv?dl=1'

addDateToFilename = (filename) ->
  splitAt   = filename.lastIndexOf('.')
  name      = filename.substring(0, splitAt)
  extension = filename.substring(splitAt)
  dateNow = new Date()
  name + '_processed-' + dateNow.getFullYear() + '-' + ('0' + (dateNow.getMonth()+1)).slice(-2) + '-' + ('0' + dateNow.getDate()).slice(-2) + '-' + dateNow.getHours() + ':' + dateNow.getMinutes() + extension

setPayload = (type, opts) ->
  payload =
    json: true
    headers: 'Authorization': token
  switch type
    when 'download'
      payload.headers['Dropbox-API-Arg'] = JSON.stringify({ path: opts.file_path })
      payload.uri = content_uri + '/files/download'
    when 'move'
      payload.uri = api_uri + '/files/move'
      payload.body =
        from_path: opts.file_path
        to_path: addDateToFilename(opts.file_path)

  payload



if argv.download
  ### coffee tasks/dropbox.coffee --download ###
  payload = setPayload 'download', { file_path: '/artwork.csv' }
  request.post payload, (err, res, body) ->
    if !err and res.statusCode is 200
      parse body, {}, (err, rows) ->
        if err then reject err
        # rows.shift()
        # resolve rows
        console.log rows[0]
        console.log rows.length
        process.exit()
    else
      console.log 'err', err
      console.log 'body', body
      process.exit()

else if argv.move
  ### coffee tasks/dropbox.coffee --move ###
  payload = setPayload 'move', { file_path: '/artwork.csv' }
  sequelize.query 'select count(*) from "Users";', { type: sequelize.QueryTypes.SELECT }
  .then (count) ->
    console.log count
    process.exit()
  # request.post payload, (err, res, body) ->
  #   if !err and res.statusCode is 200
  #     console.log res
  #     console.log body
  #     process.exit()
  #   else
  #     console.log 'err', err
  #     process.exit()

else
  console.log "No scenario was matched"
  console.log 'NODE_ENV', process.env.NODE_ENV
  process.exit()
