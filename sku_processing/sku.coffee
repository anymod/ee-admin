_         = require 'lodash'
Promise   = require 'bluebird'
sequelize = require '../config/sequelize/setup'

utils = require '../utils'
mappings = require './doba.mappings'

fns = {}

fns.editableAttrs = ['supply_price', 'supply_shipping_price', 'quantity', 'msrp', 'discontinued', 'tags']

fns.findAll = () ->
  sequelize.query 'SELECT id, identifier, supplier_id, supply_price, supply_shipping_price, quantity, msrp, auto_pricing, discontinued, other, tags1, tags2, tags3 FROM "Skus"', { type: sequelize.QueryTypes.SELECT }

fns.findAllWithoutTags = () ->
  sequelize.query 'SELECT id, identifier, supplier_id, supply_price, supply_shipping_price, quantity, msrp, auto_pricing, discontinued, other, tags FROM "Skus" WHERE tags = \'{}\' OR tags is null', { type: sequelize.QueryTypes.SELECT }

fns.findAllByProductId = (product_id) ->
  sequelize.query 'SELECT * FROM "Skus" WHERE product_id = ?', { type: sequelize.QueryTypes.SELECT, replacements: [product_id] }

fns.findByIdentifierAndSupplierId = (identifier, supplier_id) ->
  if supplier_id then supplier_id = parseInt(supplier_id)
  sequelize.query 'SELECT id, identifier, supplier_id, supply_price, supply_shipping_price, quantity, msrp, auto_pricing, discontinued FROM "Skus" where identifier = ? AND supplier_id = ?', { type: sequelize.QueryTypes.SELECT, replacements: [identifier, supplier_id] }

fns.countTagAtLevel = (tag, level) ->
  # console.log 'tag, level', tag, level
  throw 'Missing tag or level' unless tag and level
  q = 'SELECT count(*) FROM "Skus" WHERE tags' + level + ' @> \'{' + tag + '}\' AND discontinued = false AND hide_from_catalog = false AND quantity > 0'
  sequelize.query q, { type: sequelize.QueryTypes.SELECT }
  .then (res) -> parseInt(res[0].count)

fns.createFrom = (data, info) ->
  data ||= {}
  info ||= {}
  q = 'INSERT INTO "Skus" ("product_id", "identifier", "baseline_price", "shipping_price", "msrp", "selection_text", "quantity", "discontinued", "supplier_id", "supplier_name", "manufacturer_name", "brand_name", "supply_shipping_price", "supply_price", "meta", "other", "created_at", "updated_at") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) RETURNING *'
  sequelize.query q, { type: sequelize.QueryTypes.INSERT, replacements: [data.product_id, data.identifier, data.baseline_price, data.shipping_price, data.msrp, data.selection_text, data.quantity, data.discontinued, data.supplier_id, data.supplier_name, data.manufacturer_name, data.brand_name, data.supply_shipping_price, data.supply_price, JSON.stringify(data.meta), JSON.stringify(data.other), utils.timestamp(), utils.timestamp()] }
  .then (res) ->
    info.skus?.created++
    info.skus?.created_ids?.push res[0].id
    res[0]

  # if data.additional_images?.length > 0
  #   additional_images = 'ARRAY[\'' + data.additional_images.join("\',\'") + '\']::VARCHAR(255)[]'
  #   q = q.replace('ARRAY[]::VARCHAR(255)[]', additional_images)
  # sequelize.query q, { type: sequelize.QueryTypes.INSERT, replacements: [data.title, data.content, data.external_identity, data.image, data.category_id, utils.timestamp(), utils.timestamp()] }
  # .then (res) -> res[0]

fns.removeByIdentifierAndSupplierId = (identifier, supplier_id) ->
  if supplier_id then supplier_id = parseInt(supplier_id)
  sequelize.query 'UPDATE "Skus" SET hide_from_catalog = true WHERE identifier = ? AND supplier_id = ? AND hide_from_catalog IS NOT true', { type: sequelize.QueryTypes.UPDATE, replacements: [identifier, supplier_id] }

fns.updatePricing = (sku) ->
  return unless sku? and sku.id? and sku.baseline_price? and sku.shipping_price?
  q = 'UPDATE "Skus" SET baseline_price = ' + parseInt(sku.baseline_price) +
    ', shipping_price = ' + parseInt(sku.shipping_price) +
    ' WHERE id = ? '
  sequelize.query q, { type: sequelize.QueryTypes.UPDATE, replacements: [sku.id] }

fns.updateAttrs = (obj) ->
  return if !obj or !obj.identifier or Object.keys(obj).length < 2
  q = 'UPDATE "Skus" SET '
  for attr, i in fns.editableAttrs
    unless _.isUndefined obj[attr]
      q += '"' + attr + '" = ' + obj[attr] + ", "
  q += ' "updated_at" = ' + "'" + utils.timestamp() + "' "
  q += ' WHERE "identifier" = ? '
  console.log q
  sequelize.query q, { type: sequelize.QueryTypes.UPDATE, replacements: [obj.identifier] }

fns.updateSkus = (reference_skus) ->
  # reference_skus is an array of objects:
  # {
  #   identifier
  #   supplier_id
  #   supply_shipping_price
  #   supply_price
  #   quantity
  #   msrp
  #   discontinued
  # }
  info =
    count:
      total: 0
      updated:
        total: 0
      unchanged: 0
      not_found: 0
      large_price_change: 0
    not_found_identifiers: []
    large_price_change_identifiers: []
  info.count.updated[attr] = 0 for attr in fns.editableAttrs
  Promise.reduce reference_skus, ((total, sku) -> fns.updateSku(sku, info)), 0
  .then () -> info

fns.updateSku = (reference_sku, info) ->
  return if !reference_sku or !reference_sku.identifier
  info ||= {}
  fns.findByIdentifierAndSupplierId reference_sku.identifier, reference_sku.supplier_id
  .then (res) ->
    sku = res[0]
    # Handle not_found
    if !sku or !sku.id
      info.skus?.not_found++
      info.skus?.not_found_ids?.push reference_sku.identifier
      return 'not_found'
    toUpdate = []
    for attr in fns.editableAttrs
      if reference_sku[attr] isnt sku[attr] then toUpdate.push attr
    # Handle unchanged
    if toUpdate.length is 0
      info.skus?.unchanged++
      return 'unchanged'
    # Handle updates
    info.skus?.updated++
    info.skus?.updated_attrs[attr]++ for attr in toUpdate
    if (reference_sku.supply_price > sku.supply_price * 1.2) or (reference_sku.supply_shipping_price > sku.supply_shipping_price * 1.2)
      info.skus?.large_price_change++
      info.skus?.large_price_change_ids?.push reference_sku.id
    fns.updateAttrs reference_sku

fns.updateSkusSpelling = (reference_skus) ->
  info = {}
  Promise.reduce reference_skus, ((total, sku) -> fns.updateSkuSpelling(sku, info)), 0
  .then () ->
    utils.setStatus 'spelling', 'Updated ' + reference_skus.length + ' skus'
    info

fns.updateSkuSpelling = (reference_sku, info) ->
  return if !reference_sku or !reference_sku.id or !reference_sku.selection_text
  q = 'UPDATE "Skus" SET selection_text = ?, updated_at = ? WHERE id = ?'
  sequelize.query q, { type: sequelize.QueryTypes.UPDATE, replacements: [reference_sku.selection_text, utils.timestamp(), reference_sku.id] }

fns.removeSkusFromPairs = (pairs) ->
  skus_to_remove = _.map pairs, 'sku'
  throw 'Missing skus to remove' unless skus_to_remove?.length > 0
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
      hidden: 0
      not_found: 0
      large_price_change: 0
      created_ids: []
      large_price_change_ids: []
      not_found_ids: []
      hidden_ids: []
  initial_count = 0
  sequelize.query 'SELECT count(*) FROM "Skus" WHERE hide_from_catalog IS true', { type: sequelize.QueryTypes.COUNT }
  .then (res) ->
    initial_count = parseInt(res[0][0].count)
    Promise.reduce skus_to_remove, ((total, sku) -> fns.removeSku(sku)), 0
  .then () ->
    sequelize.query 'SELECT count(*) FROM "Skus" WHERE hide_from_catalog IS true', { type: sequelize.QueryTypes.COUNT }
  .then (res) ->
    info.skus.hidden = parseInt(res[0][0].count) - initial_count
    console.log 'info.skus.hidden', info.skus.hidden
    info

fns.removeSku = (sku_to_remove) ->
  return if !sku_to_remove?.identifier? or !sku_to_remove.supplier_id
  fns.removeByIdentifierAndSupplierId sku_to_remove.identifier, sku_to_remove.supplier_id

fns.updateTags = (reference_sku) ->
  return if !reference_sku?.id? or reference_sku.tags?.length < 1 or reference_sku.tags1?.length < 1
  reference_sku.tags2 ||= []
  reference_sku.tags3 ||= []
  for i in [1..3]
    reference_sku['tags' + i] = _.map(reference_sku['tags' + i], (t) -> utils.tagText(t))
  arr   = 'ARRAY[\'' + reference_sku.tags.join("\',\'") + '\']::VARCHAR(255)[]'
  arr   = arr.replace(/'s/g, "''s").replace(/s' /g, "s'' ")
  arr1  = 'ARRAY[\'' + reference_sku.tags1.join("\',\'") + '\']::VARCHAR(255)[]'
  arr2  = 'ARRAY[\'' + reference_sku.tags2.join("\',\'") + '\']::VARCHAR(255)[]'
  arr3  = 'ARRAY[\'' + reference_sku.tags3.join("\',\'") + '\']::VARCHAR(255)[]'
  q = 'UPDATE "Skus" SET tags = ' + arr + ', tags1 = ' + arr1 + ', tags2 = ' + arr2 + ', tags3 = ' + arr3 + ', updated_at = ? WHERE id = ?'
  sequelize.query q, { type: sequelize.QueryTypes.UPDATE, replacements: [utils.timestamp(), reference_sku.id] }

fns.processSkuTags = (reference_sku) ->
  return if !reference_sku?.id? or reference_sku.tags?.length > 0 or !reference_sku.other?.categories?
  tags = reference_sku.other.categories.replace(/'/g, "''").split(/\|\|/g)
  arr = 'ARRAY[\'' + tags.join("\',\'") + '\']::VARCHAR(255)[]'
  q = 'UPDATE "Skus" SET tags = ' + arr + ', updated_at = ? WHERE id = ?'
  sequelize.query q, { type: sequelize.QueryTypes.UPDATE, replacements: [utils.timestamp(), reference_sku.id] }

fns.flattenAllTagLevels = (reference_sku) ->
  return unless reference_sku?.id? and reference_sku.tags1 and reference_sku.tags2 and reference_sku.tags3
  tags1 = _.compact(_.uniq(_.flatten(reference_sku.tags1)))
  tags2 = _.compact(_.uniq(_.flatten(reference_sku.tags2)))
  tags3 = _.compact(_.uniq(_.flatten(reference_sku.tags3)))
  arr1 = 'ARRAY[\'' + tags1.join("\',\'") + '\']::VARCHAR(255)[]'
  arr2 = 'ARRAY[\'' + tags2.join("\',\'") + '\']::VARCHAR(255)[]'
  arr3 = 'ARRAY[\'' + tags3.join("\',\'") + '\']::VARCHAR(255)[]'
  q = 'UPDATE "Skus" SET tags1 = ' + arr1 + ', tags2 = ' + arr2 + ', tags3 = ' + arr3 + ', updated_at = ? WHERE id = ?'
  sequelize.query q, { type: sequelize.QueryTypes.UPDATE, replacements: [utils.timestamp(), reference_sku.id] }

fns.processTagMap = (reference_sku) ->
  return if !reference_sku?.id? or reference_sku.tags?.length < 1 # or reference_sku.tags.indexOf('Home decor') < 0
  tags1 = []
  tags2 = []
  for subtag in reference_sku.tags
    mapping = mappings.tags1And2[subtag]
    if mapping
      tags1.push _.map(mapping.tags1, (t) -> utils.tagText(t))
      tags2.push _.map(mapping.tags2, (t) -> utils.tagText(t))
  tags1 = _.uniq(_.flatten(tags1))
  tags2 = _.uniq(_.flatten(tags2))
  arr1 = 'ARRAY[\'' + tags1.join("\',\'") + '\']::VARCHAR(255)[]'
  arr2 = 'ARRAY[\'' + tags2.join("\',\'") + '\']::VARCHAR(255)[]'
  q = 'UPDATE "Skus" SET tags1 = ' + arr1 + ', tags2 = ' + arr2 + ', updated_at = ? WHERE id = ?'
  sequelize.query q, { type: sequelize.QueryTypes.UPDATE, replacements: [utils.timestamp(), reference_sku.id] }

module.exports = fns
