_         = require 'lodash'
Promise   = require 'bluebird'
sequelize = require '../config/sequelize/setup'

utils = require '../utils'

fns = {}

fns.editableAttrs = ['supply_price', 'supply_shipping_price', 'quantity', 'msrp', 'discontinued']

fns.findByIdentifierAndSupplierId = (identifier, supplier_id) ->
  if supplier_id then supplier_id = parseInt(supplier_id)
  sequelize.query 'SELECT id, identifier, supplier_id, supply_price, supply_shipping_price, quantity, msrp, discontinued FROM "Skus" where identifier = ? AND supplier_id = ?', { type: sequelize.QueryTypes.SELECT, replacements: [identifier, supplier_id] }

# fns.findByIdentifiers = (identifiers) ->
#   sequelize.query 'SELECT id, identifier, supplier_id, supply_price, supply_shipping_price, quantity, msrp, discontinued FROM "Skus" where identifier IN (' + identifiers + ')', { type: sequelize.QueryTypes.SELECT }

fns.updateAttrs = (obj) ->
  return if !obj or !obj.identifier or Object.keys(obj).length < 2
  q = 'UPDATE "Skus" SET '
  for attr, i in fns.editableAttrs
    unless _.isUndefined obj[attr]
      q += '"' + attr + '" = ' + obj[attr] + ", "
  q += ' "updated_at" = ' + "'" + utils.timestamp() + "' "
  q += ' WHERE "identifier" = ? '
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
      total: reference_skus.length
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
  fns.findByIdentifierAndSupplierId reference_sku.identifier, reference_sku.supplier_id
  .then (res) ->
    sku = res[0]
    # Handle not_found
    if !sku or !sku.id
      info.count.not_found++
      info.not_found_identifiers.push reference_sku.identifier
      return 'not_found'
    toUpdate = []
    for attr in fns.editableAttrs
      if reference_sku[attr] isnt sku[attr] then toUpdate.push attr
    # Handle unchanged
    if toUpdate.length is 0
      info.count.unchanged++
      return 'unchanged'
    # Handle updates
    info.count.updated.total++
    info.count.updated[attr]++ for attr in toUpdate
    if (reference_sku.supply_price > sku.supply_price * 1.2) or (reference_sku.supply_shipping_price > sku.supply_shipping_price * 1.2)
      info.count.large_price_change++
      info.large_price_change_identifiers.push reference_sku.identifier
    fns.updateAttrs reference_sku

module.exports = fns
