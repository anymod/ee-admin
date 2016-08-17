request   = require 'request'
_         = require 'lodash'
Promise   = require 'bluebird'

utils = require '../utils'

csv   = require './csv'
sku   = require './sku'
mappings = require './doba.mappings'

token       = 'Bearer 5LTVvc5TbysAAAAAAAAAESnWQj7UXc7aRyojSnPzRbM6BDcCQaY05wCYlWwKlGGC'
api_v1_uri  = 'https://api.dropboxapi.com/1'
api_uri     = 'https://api.dropboxapi.com/2'
content_uri = 'https://content.dropboxapi.com/2'

dropbox = {}

completedPathFor = (file_path) ->
  '/completed_successfully/' + utils.timestampedFilename(file_path)

archivedPathFor = (file_path) ->
  '/archive (do not edit)/' + utils.timestampedFilename(file_path, '_at_')

dropbox.categoryMappings =
  artwork:      1
  bed_bath:     2
  furniture:    3
  home_accents: 4
  kitchen:      5
  outdoor:      6

dropbox.getCategoryFromPath = (path) ->
  throw 'No path in dropbox.getCategoryFromPath' unless path?
  if path.indexOf('removal') > -1 then return 0
  for key in Object.keys(dropbox.categoryMappings)
    if path.indexOf('/files_to_process/' + key) is 0 then return dropbox.categoryMappings[key]
  throw 'No category in dropbox.getCategoryFromPath'

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
        to_path: completedPathFor(opts.file_path)
    when 'archive'
      payload.uri = api_uri + '/files/copy'
      payload.body =
        from_path: opts.file_path
        to_path: archivedPathFor(opts.file_path)
  payload

dropbox.makeRequest = (type, opts) ->
  new Promise (resolve, reject) ->
    payload = dropbox.setPayload type, opts
    request.post payload, (err, res, body) ->
      if err then return reject body
      if body.error_summary then return reject body
      resolve body

dropbox.getFolder = (path) ->
  dropbox.makeRequest 'list_folder', { folder_path: path }

dropbox.getFile = (path) ->
  dropbox.makeRequest 'download', { file_path: path }

dropbox.finishFile = (path) ->
  dropbox.makeRequest 'archive', { file_path: path }
  .then () -> dropbox.makeRequest 'move', { file_path: path }

module.exports = dropbox
