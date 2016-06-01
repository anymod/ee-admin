_         = require 'lodash'
Promise   = require 'bluebird'
sequelize = require '../config/sequelize/setup'
argv      = require('yargs').argv

sku     = require './sku'
pricing = require './pricing'

utils   = require '../utils'

if argv.bedding_vermicelli
  ### coffee sku_processing/manual.coffee --bedding_vermicelli ###
  product_count = 0
  q = "SELECT id, title, content FROM \"Products\" WHERE title ilike '[%' AND title ilike '%3PC Vermicelli%' AND title ilike '%Queen%'"
  sequelize.query q, { type: sequelize.QueryTypes.INSERT }
  .then (products) ->
    product_count = products.length
    updateSkus = (product_id) ->
      q = "UPDATE \"Skus\" SET length = 98, width = 90 WHERE product_id = ?"
      sequelize.query q, { type: sequelize.QueryTypes.UPDATE, replacements: [product_id] }
    updateProduct = (prod) ->
      style = prod.title.match(/\[.*\]/g)[0].replace(/[\[\]]/g,'')
      prod.title = style + ' Vermicelli Quilt and 2 Shams, Full or Queen Size'
      prod.content = 'Set includes a quilt and two quilted shams. Shell and fill are 100% cotton. For convenience, all bedding components are machine washable on cold in the gentle cycle and can be dried on low heat and will last you years. Intricate vermicelli quilting provides a rich surface texture. This vermicelli-quilted quilt set will refresh your bedroom decor instantly, create a cozy and inviting atmosphere and is sure to transform the look of your bedroom or guest room.\n\nDimensions: Full/Queen quilt: 90 inches x 98 inches\n2 standard shams: 20 inches x 26 inches'
      q = "UPDATE \"Products\" SET title = ?, content = ? WHERE id = ?"
      sequelize.query q, { type: sequelize.QueryTypes.UPDATE, replacements: [prod.title, prod.content, prod.id] }
      .then () -> updateSkus prod.id
    Promise.reduce products, ((total, product) -> updateProduct(product)), 0
  .then (res) ->  console.log 'finished ' + product_count + ' products'
  .catch (err) -> console.log 'err', err
  .finally () -> process.exit()

#
