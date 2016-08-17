_       = require 'lodash'
Promise = require 'bluebird'
argv    = require('yargs').argv

utils   = require '../utils'

dropbox     = require './dropbox'
cloudinary  = require './cloudinary'
es          = require './elasticsearch'
csv         = require './csv'
sku         = require './sku'
product     = require './product'
keen        = require './keen'
pricing     = require './pricing'
grammar     = require './grammar'

fns = {}

processDropboxFile = (path, status) ->
  status?.message = 'processing ' + path
  utils.setStatus 'dropbox', status
  category_id = dropbox.getCategoryFromPath(path)
  dropbox.getFile path
  .then (file) ->
    csv.parseDobaFile file, category_id
  .then (data) ->
    if category_id is 0 # set if removal
      sku.removeSkusFromPairs data
    else
      grammar.cleanPairs data
      product.createOrUpdatePairs data
  .then (info) ->
    keen.addSkuEvent info
    if status?.info_array?
      status.info_array.push info
      utils.setStatus 'dropbox', status
    dropbox.finishFile path
  .then () ->
    console.log 'status.info_array', status.info_array
    if status?.info_array?
      {
        skus_created:       _.sum(_.map(status.info_array, (el) -> el.skus.created))
        skus_updated:       _.sum(_.map(status.info_array, (el) -> el.skus.updated))
        skus_unchanged:     _.sum(_.map(status.info_array, (el) -> el.skus.unchanged))
        skus_hidden:        _.sum(_.map(status.info_array, (el) -> el.skus.hidden))
        products_created:   _.sum(_.map(status.info_array, (el) -> el.products.created))
        products_unchanged: _.sum(_.map(status.info_array, (el) -> el.products.unchanged))
      }

# processPricingFile = (path, status) ->
#   status?.message = 'processing ' + path
#   utils.setStatus 'update', status
#   dropbox.getFile path
#   .then (file) -> csv.parseSkuPricingFile file
#   .then (skus) -> sku.updateSkus skus
#   .then (info) ->
#     info.path = path
#     file_parts = path.split(/\//g)
#     info.type = file_parts[1]
#     info.filename = file_parts[file_parts.length - 1]?.replace('.csv', '')
#     keen.addSkuEvent info
#     if status?.info_array?
#       status.info_array.push info
#       utils.setStatus 'update', status
#   .then () -> dropbox.finishFile path

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

processDobaImages = (prod) ->
  additional_images = []
  options =
    public_id: prod.id
    tags: ['product', 'main_image']
    upload_preset: 'product_image'
  new Promise (resolve, reject) ->
    if !prod? or !prod.image? then resolve false
    cloudinary.uploadAsync prod.image, options
    .then (res) ->
      prod.image = res.secure_url
      uploadAdditionalImage = (url) ->
        i = prod.additional_images.indexOf(url) + 1
        options.tags[1] = 'additional_image'
        options.public_id = [prod.id, i].join('-')
        cloudinary.uploadAsync url, options
        .then (res) ->
          additional_images.push res.secure_url
      Promise.reduce prod.additional_images, ((total, url) -> uploadAdditionalImage url), 0
    .then () ->
      if additional_images.length > 0 then prod.additional_images = additional_images
      product.overwriteImagesFor prod
    .then () ->
      console.log prod
      resolve prod
    .catch (err) -> reject err

fns.processDropbox = () ->
  status =
    running: true
    message: 'fetching dropbox folder'
    info_array: []
  utils.setStatus 'dropbox', status
  dropbox.getFolder '/files_to_process'
  .then (rows) ->
    files = _.filter rows.entries, { '.tag': 'file' }
    if !files or files.length < 1 then throw 'no files found in /files_to_process'
    Promise.reduce files, ((total, file) -> processDropboxFile file.path_lower, status), 0
  .then (message) ->
    status.message = 'completed ' + status.info_array.length + ' files '
    if message
      status.message += '(sku: ' + message.skus_created + ' created; ' + message.skus_updated + ' updated; ' + message.skus_hidden + ' hidden; ' + message.skus_unchanged + ' unchanged) '
      status.message += '(product: ' + message.products_created + ' created; ' + message.products_unchanged + ' unchanged)'
  .catch (err) -> status.err = err
  .finally () ->
    status ||= {}
    status.running = false
    utils.setStatus 'dropbox', status

# fns.updateFromDropbox = () ->
#   status =
#     running: true
#     message: 'fetching update folder'
#     info_array: []
#   utils.setStatus 'update', status
#   dropbox.getFolder '/update'
#   .then (rows) ->
#     files = _.filter rows.entries, { '.tag': 'file' }
#     if !files or files.length < 1 then throw 'no files found in /update'
#     Promise.reduce files, ((total, file) -> processPricingFile file.path_lower, status), 0
#   .then () -> status.message = 'completed ' + status.info_array.length + ' update files'
#   .catch (err) -> status.err = err
#   .finally () ->
#     status ||= {}
#     status.running = false
#     utils.setStatus 'update', status

fns.indexElasticsearch = () ->
  status =
    running: true
    message: 'deleting existing index'
    info_array: []
  utils.setStatus 'elasticsearch', status
  es.deleteNestedIndex()
  .then (res) ->
    if res isnt true then status.info_array.push { deleteNestedIndex: res }
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
    status ||= {}
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
    status ||= {}
    status.running = false
    utils.setStatus 'pricing', status

fns.setTags = () ->
  status =
    running: true
    message: 'reading skus'
  n_skus = 0
  utils.setStatus 'tags', status
  sku.findAll()
  .then (skus) ->
    n_skus = skus.length
    status.message = 'adding tags for ' + n_skus + ' skus'
    utils.setStatus 'tags', status
    Promise.reduce skus, ((total, s) -> sku.processSkuTags(s)), 0
  .then () ->
    status.message = 'added new tags'
  .catch (err) -> status.err = err
  .finally () ->
    status ||= {}
    status.running = false
    utils.setStatus 'tags', status


# fns.setCloudinaryImages = () ->
#   url = 'http://images.doba.com/products/3797/img_bloemliving_27060_6.jpg'
#   options =
#     public_id: 5153
#     tags: ['test', 'foobarbaz']
#     # format: 'jpg'
#     upload_preset: 'product_image'
#   cloudinary.uploadAsync(url, options)
#   .then (res) -> res.secure_url

if argv.dropbox
  ### coffee sku_processing/runner.coffee --dropbox ###
  fns.processDropbox()
  .then (res) -> console.log res
  .catch (err) -> console.log 'err', err
  .finally () -> process.exit()

else if argv.cloudinary
  ### coffee sku_processing/runner.coffee --cloudinary ###
  products = []
  product.findAllWithDobaImage()
  .then (res) ->
    console.log '' + res.length + ' products remaining'
    products = _.slice res, 0, 100
    Promise.reduce products, ((total, prod) -> processDobaImages(prod)), 0
  .then () -> console.log 'Finished:', products
  .catch (err) -> console.log 'err', err
  .finally () -> process.exit()

else if argv.tags
  ### coffee sku_processing/runner.coffee --tags ###
  fns.setTags()
  .then (res) -> console.log res
  .catch (err) -> console.log 'err', err
  .finally () -> process.exit()

# if argv.update
#   ### coffee sku_processing/runner.coffee --update ###
#   fns.processDropbox()
#   .then (res) ->
#     console.log 'res', res
#   .catch (err) ->
#     console.log 'err', err
#   .finally () -> process.exit()
# if argv.update_pricing
#   ### coffee sku_processing/runner.coffee --update_pricing ###
#   fns.runPricingAlgorithm()
#   .then () -> console.log 'Finished'
#   .catch (err) -> console.log err
#   .finally () -> process.exit()
#
# else if argv.update_sku_spelling
#   ### coffee sku_processing/runner.coffee --update_sku_spelling ###
#   utils.setStatus 'spelling', 'Starting sku spelling update'
#   dropbox.getFolder '/additional/sku_spelling'
#   .then (rows) ->
#     files = _.filter rows.entries, { '.tag': 'file' }
#     if !files or files.length < 1 then throw 'no files found in /additional/sku_spelling'
#     Promise.reduce files, ((total, file) -> processSkuSpellingFile file.path_lower), 0
#   .catch (err) -> console.log err
#   .finally () ->
#     process.exit()
#
# else if argv.update_product_spelling
#   ### coffee sku_processing/runner.coffee --update_product_spelling ###
#   utils.setStatus 'spelling', 'Starting product spelling update'
#   dropbox.getFolder '/additional/product_spelling'
#   .then (rows) ->
#     files = _.filter rows.entries, { '.tag': 'file' }
#     if !files or files.length < 1 then throw 'no files found in /additional/product_spelling'
#     Promise.reduce files, ((total, file) -> processProductSpellingFile file.path_lower), 0
#   .catch (err) -> console.log err
#   .finally () ->
#     process.exit()
#
# fns.indexElasticsearch()
# .then (message) ->
#   console.log 'finished ' + message
# .catch (err) -> console.log err
# .finally () -> process.exit()
#
# if argv.finish
#   ### coffee sku_processing/runner.coffee --finish ###
#   dropbox.finishFile '/update/kitchen_short.csv'
#   .then (res) ->
#     console.log 'finished', res
#   .catch (err) ->
#     console.log 'err', err
#   .finally () -> process.exit()
#
# else
#   console.log "No scenario was matched"
#   console.log 'NODE_ENV', process.env.NODE_ENV
#   process.exit()

module.exports = fns
