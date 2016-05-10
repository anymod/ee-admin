_         = require 'lodash'
Promise   = require 'bluebird'
sequelize = require '../config/sequelize/setup'

sku     = require './sku'
pricing = require './pricing'

utils   = require '../utils'

fns = {}

fns.createFrom = (data, info) ->
  data ||= {}
  info ||= {}
  q = 'INSERT INTO "Products" ("title", "content", "external_identity", "image", "additional_images", "category_id", "created_at", "updated_at") VALUES (?, ?, ?, ?, ARRAY[]::VARCHAR(255)[], ?, ?, ?) RETURNING *'
  if data.additional_images?.length > 0
    additional_images = 'ARRAY[\'' + data.additional_images.join("\',\'") + '\']::VARCHAR(255)[]'
    q = q.replace('ARRAY[]::VARCHAR(255)[]', additional_images)
  sequelize.query q, { type: sequelize.QueryTypes.INSERT, replacements: [data.title, data.content, data.external_identity, data.image, data.category_id, utils.timestamp(), utils.timestamp()] }
  .then (res) ->
    info.products?.created++
    info.products?.created_ids?.push res[0].id
    res[0]

fns.findOrCreate = (data, info) ->
  throw 'No external_identity' unless data?.external_identity?
  info ||= {}
  sequelize.query 'SELECT * FROM "Products" WHERE external_identity = ?', { type: sequelize.QueryTypes.SELECT, replacements: [data.external_identity] }
  .then (res) ->
    if res? and res[0]?
      info.products?.unchanged++
      return res[0]
    fns.createFrom data, info

fns.updateProductsSpelling = (reference_products) ->
  info = {}
  Promise.reduce reference_products, ((total, product) -> fns.updateProductSpelling(product, info)), 0
  .then () ->
    utils.setStatus 'spelling', 'Updated ' + reference_products.length + ' products'
    info

fns.updateProductSpelling = (reference_product, info) ->
  return if !reference_product or !reference_product.id or !reference_product.title
  q = 'UPDATE "Products" SET title = ?, content = ?, updated_at = ? WHERE id = ?'
  sequelize.query q, { type: sequelize.QueryTypes.UPDATE, replacements: [reference_product.title, reference_product.content, utils.timestamp(), reference_product.id] }

fns.findOrUpdateProductAndSku = (pair, info) ->
  throw 'Invalid pair' unless pair?.sku?.identifier? and pair?.sku?.supplier_id? and pair?.product?.external_identity?
  sku.findByIdentifierAndSupplierId(pair.sku.identifier, pair.sku.supplier_id)
  .then (res) ->
    obj = pricing.getValues(pair.sku.supply_price, pair.sku.supply_shipping_price)
    pair.sku[attr] = obj[attr] for attr in Object.keys(obj)
    if res[0]? # If sku exists, update it (product already exists too)
      info?.products?.unchanged++
      sku.updateSku pair.sku, info
    else    # If no sku, find or create product, then create sku
      fns.findOrCreate pair.product, info
      .then (product) ->
        pair.sku.product_id = product.id
        sku.createFrom pair.sku, info
  .then () ->
    return {}

fns.createOrUpdatePairs = (pairs) ->
  info =
    products:
      created: 0
      unchanged: 0
      created_ids: []
    skus:
      created: 0
      updated: 0
      updated_attrs: {}
      unchanged: 0
      not_found: 0
      large_price_change: 0
      created_ids: []
      large_price_change_ids: []
      not_found_ids: []
  info.skus.updated_attrs[attr] = 0 for attr in sku.editableAttrs
  Promise.reduce pairs, ((total, pair) -> fns.findOrUpdateProductAndSku(pair, info)), 0
  .then () -> info

module.exports = fns
