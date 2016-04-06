_       = require 'lodash'
Promise = require 'bluebird'
argv    = require('yargs').argv

utils   = require '../utils'

dropbox = require './dropbox'
es      = require './elasticsearch'
csv     = require './csv'
sku     = require './sku'
keen    = require './keen'

fns = {}

processFile = (path, status) ->
  status?.message = 'processing ' + path
  utils.setStatus 'update', status
  dropbox.getFile path
  .then (file) -> csv.parseFile file
  .then (skus) ->
    # console.log 'skus', skus
    sku.updateSkus skus
  .then (info) ->
    info.path = path
    file_parts = path.split(/\//g)
    info.type = file_parts[1]
    info.filename = file_parts[file_parts.length - 1]?.replace('.csv', '')
    keen.addSkuEvent info
    if status?.info_array?
      status.info_array.push info
      utils.setStatus 'update', status
  .then () -> dropbox.finishFile path


fns.updateFromDropbox = () ->
  status =
    running: true
    message: 'fetching update folder'
    info_array: []
  utils.setStatus 'update', status
  dropbox.getFolder '/update'
  .then (rows) ->
    files = _.filter rows.entries, { '.tag': 'file' }
    if !files or files.length < 1 then throw 'no files found in /update'
    Promise.reduce files, ((total, file) -> processFile file.path_lower, status), 0
  .then () -> status.message = 'completed ' + status.info_array.length + ' update files'
  .catch (err) -> status.err = err
  .finally () ->
    status.running = false
    utils.setStatus 'update', status

fns.indexElasticsearch = () ->
  status =
    running: true
    message: 'deleting existing index'
    info_array: []
  utils.setStatus 'elasticsearch', status
  es.deleteIndex()
  .then () ->
    status.message = 'building new index'
    utils.setStatus 'elasticsearch', status
    es.createIndex()
  .then () ->
    status.message = 'populating new index'
    utils.setStatus 'elasticsearch', status
    es.bulkIndex()
  .then (n) -> status.message = 'indexed ' + n + ' products'
  .catch (err) -> status.err = err
  .finally () ->
    status.running = false
    utils.setStatus 'elasticsearch', status

# fns.indexElasticsearch()
# .then (message) ->
#   console.log 'finished ' + message
# .catch (err) -> console.log err
# .finally () -> process.exit()


# if argv.finish
#   ### coffee sku_processing/runner.coffee --finish ###
#   dropbox.finishFile '/update/kitchen_short.csv'
#   .then (res) ->
#     console.log 'finished', res
#   .catch (err) ->
#     console.log 'err', err
#   .finally () -> process.exit()
#
# if argv.update
#   ### coffee sku_processing/runner.coffee --update ###
#   fns.updateFromDropbox()
#   .then (res) ->
#     console.log 'res', res
#   .catch (err) ->
#     console.log 'err', err
#   .finally () -> process.exit()
#
# else
#   console.log "No scenario was matched"
#   console.log 'NODE_ENV', process.env.NODE_ENV
#   process.exit()

module.exports = fns
