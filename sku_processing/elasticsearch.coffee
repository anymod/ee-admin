_             = require 'lodash'
Promise       = require 'bluebird'
argv          = require('yargs').argv

elasticsearch = require '../config/elasticsearch/setup'
sequelize     = require '../config/sequelize/setup'

fns = {}

index_attrs =
  product:
    id:                 type: 'integer'
    image:              type: 'string'
    external_identity:  type: 'string'
    additional_images:  type: 'string'
    title:
      type: 'string'
      analyzer: 'english'
      fields:
        raw:
          type: 'string'
          index: 'not_analyzed'
    content:            type: 'string', analyzer: 'english' #, fields: { english: { type: 'string', analyzer: 'english' } }
    category_id:        type: 'integer'
    created_at:         type: 'date'
    updated_at:         type: 'date'
  sku:
    id:               type: 'integer'
    product_id:       type: 'integer'
    supplier_id:      type: 'integer'
    identifier:       type: 'string'
    baseline_price:   type: 'integer'
    msrp:             type: 'integer'
    shipping_price:   type: 'integer'
    selection_text:   type: 'string'
    style:            type: 'string'
    color:            type: 'string'
    material:         type: 'string'
    length:           type: 'long'
    width:            type: 'long'
    height:           type: 'long'
    weight:           type: 'long'
    size:             type: 'string'
    quantity:         type: 'integer'
    discontinued:     type: 'boolean'
    supply_price:     type: 'integer'
    supply_shipping_price: type: 'integer'
    hide_from_catalog: type: 'boolean'
    tags:             type: 'string'

# indexable_attrs =
#   sku: [
#     'id'
#     'product_id'
#     'baseline_price'
#     'msrp'
#     'shipping_price'
#     'style'
#     'color'
#     'material'
#     'length'
#     'width'
#     'height'
#     'weight'
#     'size'
#     'supply_price'
#     'supply_shipping_price'
#   ]

read_attrs =
  sku: [
    'id'
    'product_id'
    'baseline_price'
    'msrp'
    'shipping_price'
    'style'
    'color'
    'material'
    'length'
    'width'
    'height'
    'weight'
    'size'
    'quantity'
    'discontinued'
    'hide_from_catalog'
    'tags'
  ]

### NESTING ###

es_index = 'nested_search' # 'test_search'

addProductWithNesting = (body, product, count) ->
  sequelize.query 'SELECT * FROM "Skus" where product_id = ? AND discontinued is not true AND quantity > 0', { type: sequelize.QueryTypes.SELECT, replacements: [product.id] }
  .then (skus) ->
    return if skus.length is 0
    count.products++
    count?.skus += skus.length
    product.skus = _.map(skus, (sku) -> _.pick(sku, read_attrs.sku ))
    body.push { index: { _index: es_index, _type: 'product', _id: product.id } }
    body.push product

fns.deleteNestedIndex = () ->
  new Promise (resolve, reject) ->
    elasticsearch.client.indices.delete({ index: es_index })
    .then () -> resolve true
    .catch (err) -> resolve err

fns.createNestedIndex = () ->
  product_properties = index_attrs.product
  product_properties.skus =
    type: 'nested'
    properties: index_attrs.sku
  new Promise (resolve, reject) ->
    elasticsearch.client.indices.create({
      index: es_index
      body:
        settings:
          number_of_shards: 1
          analysis:
            analyzer: 'standard'
        mappings:
          product:
            properties: product_properties

    })
    .then () -> resolve true

fns.bulkNestedIndex = () ->
  bulk_body = []
  count =
    products: 0
    skus: 0
  sequelize.query 'SELECT * FROM "Products" limit 10000', { type: sequelize.QueryTypes.SELECT }
  .then (products) ->
    Promise.reduce products, ((total, product) -> addProductWithNesting(bulk_body, product, count)), 0
  .then () -> elasticsearch.client.bulk body: bulk_body
  .then () -> count

# fns.deleteNestedIndex()
# .then () -> fns.createNestedIndex()
# .then () -> fns.bulkNestedIndex()
# .then (count) ->
#   console.log 'Finished ' + count.products + ' products + ' + count.skus + ' skus'
# .catch (err) -> console.log err
# .finally () -> process.exit()

module.exports = fns
