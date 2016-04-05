request   = require 'request'
_         = require 'lodash'
Promise   = require 'bluebird'

utils = '../utils'

csv   = require './csv'
sku   = require './sku'
mappings = require './doba.mappings'

token       = 'Bearer 5LTVvc5TbysAAAAAAAAAESnWQj7UXc7aRyojSnPzRbM6BDcCQaY05wCYlWwKlGGC'
api_v1_uri  = 'https://api.dropboxapi.com/1'
api_uri     = 'https://api.dropboxapi.com/2'
content_uri = 'https://content.dropboxapi.com/2'

dropbox = {}

dropbox.setPayload = (type, opts) ->
  payload =
    json: true
    headers: 'Authorization': token
  switch type
    when 'list_folder'
      payload.uri = api_uri + '/files/list_folder'
      payload.body =
        path: opts.folder_path
    when 'download'
      payload.headers['Dropbox-API-Arg'] = JSON.stringify({ path: opts.file_path })
      payload.uri = content_uri + '/files/download'
    when 'move'
      payload.uri = api_uri + '/files/move'
      payload.body =
        from_path: opts.file_path
        to_path: csv.addDateToFilename(opts.file_path)
  payload

dropbox.makeRequest = (type, opts) ->
  new Promise (resolve, reject) ->
    payload = dropbox.setPayload type, opts
    request.post payload, (err, res, body) ->
      if err then reject body else resolve body

dropbox.getFolder = (path) ->
  dropbox.makeRequest 'list_folder', { folder_path: path }

dropbox.getFile = (path) ->
  dropbox.makeRequest 'download', { file_path: path }


module.exports = dropbox
