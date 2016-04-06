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
    discontinued:       type: 'boolean'
    hide_from_catalog:  type: 'boolean'
    additional_images:  type: 'string'
    title:              type: 'string', analyzer: 'english' #, fields: { english: { type: 'string', analyzer: 'english' } }
    content:            type: 'string', analyzer: 'english' #, fields: { english: { type: 'string', analyzer: 'english' } }
    category_id:        type: 'integer'
    created_at:         type: 'date'
    updated_at:         type: 'date'
  sku:
    id:               type: 'integer'
    product_id:       type: 'integer'
    supplier_id:      type: 'integer'
    identifier:       type: 'string'
    # baseline_price:   type: 'integer'
    regular_price:    type: 'integer'
    msrp:             type: 'integer'
    shipping_price:   type: 'integer'
    selection_text:   type: 'string'
    subcontent:       type: 'string'
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

read_attrs =
  sku: [
    'id'
    'product_id'
    'regular_price'
    'msrp'
  ]

addSkusForElasticsearch = (body, product, count) ->
  sequelize.query 'SELECT * FROM "Skus" where product_id = ?', { type: sequelize.QueryTypes.SELECT, replacements: [product.id] }
  .then (skus) ->
    count?.skus += skus.length
    product.skus = _.map(skus, (sku) -> _.pick(sku, read_attrs.sku ))
    body.push { index: { _index: 'products_search', _type: 'product', _id: product.id } }
    body.push product
    for sku in skus
      body.push { index: { _index: 'products_search', _type: 'sku', _id: sku.id, _parent: product.id } }
      body.push sku

fns.deleteIndex = () ->
  new Promise (resolve) -> resolve true
  # elasticsearch.client.indices.delete { index: 'products_search' }

fns.createIndex = () ->
  new Promise (resolve) -> resolve true
  # elasticsearch.client.indices.create({
  #   index: 'products_search'
  #   body:
  #     settings:
  #       number_of_shards: 1
  #       analysis:
  #         analyzer: 'english'
  #           # english:
  #           #   tokenizer: 'standard'
  #           #   filter: ['lowercase']
  #     mappings:
  #       product:
  #         properties: index_attrs.product
  #       sku:
  #         _parent: type: 'product'
  #         properties: index_attrs.sku
  #
  # })

fns.bulkIndex = () ->
  bulk_body = []
  count =
    products: 0
    skus: 0
  sequelize.query 'SELECT * FROM "Products" limit 10000', { type: sequelize.QueryTypes.SELECT }
  .then (products) ->
    count.products = products.length
    Promise.reduce products, ((total, product) -> addSkusForElasticsearch(bulk_body, product, count)), 0
  .then () ->
    count
  # .then () -> elasticsearch.client.bulk body: bulk_body

# fns.bulkIndex()
# .then (n) ->
#   console.log 'finished ' + n
# .catch (err) -> console.log err
# .finally () -> process.exit()

module.exports = fns
