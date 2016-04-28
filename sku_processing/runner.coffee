_       = require 'lodash'
Promise = require 'bluebird'
argv    = require('yargs').argv

utils   = require '../utils'

dropbox = require './dropbox'
es      = require './elasticsearch'
csv     = require './csv'
sku     = require './sku'
product = require './product'
keen    = require './keen'
pricing = require './pricing'

fns = {}

processPricingFile = (path, status) ->
  status?.message = 'processing ' + path
  utils.setStatus 'update', status
  dropbox.getFile path
  .then (file) -> csv.parseSkuPricingFile file
  .then (skus) -> sku.updateSkus skus
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

processSkuSpellingFile = (path, status) ->
  utils.setStatus 'spelling', 'Processing skus in ' + path
  dropbox.getFile path
  .then (file) -> csv.parseSkuSelectionTextFile file
  .then (skus) -> sku.updateSkusSpelling skus
  .then () -> dropbox.finishFile path

processProductSpellingFile = (path, status) ->
  utils.setStatus 'spelling', 'Processing products in ' + path
  dropbox.getFile path
  .then (file) -> csv.parseProductTitleAndContentFile file
  .then (products) -> product.updateProductsSpelling products
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
    Promise.reduce files, ((total, file) -> processPricingFile file.path_lower, status), 0
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
  es.deleteNestedIndex()
  .then () ->
    status.message = 'building new index'
    utils.setStatus 'elasticsearch', status
    es.createNestedIndex()
  .then () ->
    status.message = 'populating new index'
    utils.setStatus 'elasticsearch', status
    es.bulkNestedIndex()
  .then (count) ->
    keen.addElasticsearchIndexEvent { count: count }
    status.message = 'indexed ' + count.products + ' products + ' + count.skus + ' skus'
    status.info_array.push { count: count }
  .catch (err) -> status.err = err
  .finally () ->
    status.running = false
    utils.setStatus 'elasticsearch', status

fns.runPricingAlgorithm = () ->
  status =
    running: true
    message: 'reading skus'
    manual_pricing: []
  n_skus = 0
  utils.setStatus 'pricing', status
  sku.findAll()
  .then (skus) ->
    n_skus = skus.length
    status.message = 'updating pricing for ' + n_skus + ' skus'
    utils.setStatus 'pricing', status
    updateSku = (s) ->
      obj = pricing.getValues(s.supply_price, s.supply_shipping_price)
      s[attr] = obj[attr] for attr in Object.keys(obj)
      if s.auto_pricing
        sku.updatePricing(s)
      else
        status.manual_pricing.push { id: s.id, identifier: s.identifier }
    Promise.reduce skus, ((total, s) -> updateSku(s)), 0
  .then () ->
    status.message = 'updated pricing for ' + (n_skus - status.manual_pricing.length) + ' skus; ' + status.manual_pricing.length + ' skipped due to manual pricing'
  .catch (err) -> status.err = err
  .finally () ->
    status.running = false
    utils.setStatus 'pricing', status

# fns.indexElasticsearch()
# .then (message) ->
#   console.log 'finished ' + message
# .catch (err) -> console.log err
# .finally () -> process.exit()

if argv.update_pricing
  ### coffee sku_processing/runner.coffee --update_pricing ###
  fns.runPricingAlgorithm()
  .then () -> console.log 'Finished'
  .catch (err) -> console.log err
  .finally () -> process.exit()

else if argv.update_sku_spelling
  ### coffee sku_processing/runner.coffee --update_sku_spelling ###
  utils.setStatus 'spelling', 'Starting sku spelling update'
  dropbox.getFolder '/additional/sku_spelling'
  .then (rows) ->
    files = _.filter rows.entries, { '.tag': 'file' }
    if !files or files.length < 1 then throw 'no files found in /additional/sku_spelling'
    Promise.reduce files, ((total, file) -> processSkuSpellingFile file.path_lower), 0
  .catch (err) -> console.log err
  .finally () ->
    process.exit()

else if argv.update_product_spelling
  ### coffee sku_processing/runner.coffee --update_product_spelling ###
  utils.setStatus 'spelling', 'Starting product spelling update'
  dropbox.getFolder '/additional/product_spelling'
  .then (rows) ->
    files = _.filter rows.entries, { '.tag': 'file' }
    if !files or files.length < 1 then throw 'no files found in /additional/product_spelling'
    Promise.reduce files, ((total, file) -> processProductSpellingFile file.path_lower), 0
  .catch (err) -> console.log err
  .finally () ->
    process.exit()

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
