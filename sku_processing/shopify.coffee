fs        = require 'fs'
_         = require 'lodash'
Promise   = require 'bluebird'
csv       = require 'csv'
sequelize = require '../config/sequelize/setup'
argv      = require('yargs').argv

product = require './product'
sku     = require './sku'
pricing = require './pricing'

utils   = require '../utils'

header = [
  'Handle'
  'Title'
  'Body (HTML)'
  'Vendor'
  'Type'
  'Tags'
  'Published'
  'Option1 Name'
  'Option1 Value'
  'Option2 Name'
  'Option2 Value'
  'Option3 Name'
  'Option3 Value'
  'Variant SKU'
  'Variant Grams'
  'Variant Inventory Tracker'
  'Variant Inventory Qty'
  'Variant Inventory Policy'
  'Variant Fulfillment Service'
  'Variant Price'
  'Variant Compare At Price'
  'Variant Requires Shipping'
  'Variant Taxable'
  'Variant Barcode'
  'Image Src'
]

processProduct = (prod, output) ->
  return unless prod?.id
  return if prod.hide_from_catalog
  handle = utils.tagText(prod.title) + '-P' + prod.id
  rowTemplate = [
    handle
    prod.title
    prod.content
    null # Vendor
  ]
  # setImageRowsFor prod
  setSkuRowsFor prod, rowTemplate
  .then (skuRows) ->
    for additional_image in prod.additional_images
      imageRow = [handle].concat _.fill(new Array(23), null)
      imageRow.push(additional_image)
      skuRows.push imageRow
    for row in skuRows
      output.push row

setSkuRowsFor = (prod, rowTemplate) ->
  return unless prod?.id
  rows = []
  sku.findAllByProductId prod.id
  .then (skus) ->
    for s in skus
      vals = [
        if s.tags1 then _.compact(s.tags1).join(',') else null
        if s.tags2 then _.compact(s.tags2).concat(_.compact(s.tags3)).join(',') else null
        (if s.discontinued or s.hide_from_catalog then 'FALSE' else 'TRUE')
        'Title'
        (if skus.length > 1 then s.selection_text else 'Default Title')
        null
        null
        null
        null
        s.id
        s.weight
        'shopify'
        s.quantity
        'deny'
        'Manual'
        pricing.getPrice(s.baseline_price, 95, [.02,.02,.02,.02,.02]) / 100
        s.msrp / 100
        'TRUE'
        null
        null
        prod.image
      ]
      rows.push rowTemplate.concat(vals)
    rows

if argv.export
  ### coffee sku_processing/shopify.coffee --export ###
  output = [header]
  product.findAll()
  .then (products) ->
    # prods = _.sampleSize products, 10
    Promise.reduce products, ((total, prod) -> processProduct prod, output), 0
  .then () ->
    csv.stringify output, (err, stringified) ->
      if err then throw err
      fs.writeFileSync 'csv/shopify-' + utils.fileTimestamp() + '.csv', stringified
      process.exit()
  .catch (err) -> console.log 'err', err
