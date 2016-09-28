fs        = require 'fs'
_         = require 'lodash'
Promise   = require 'bluebird'
sequelize = require '../config/sequelize/setup'
argv      = require('yargs').argv

product = require './product'
sku     = require './sku'
pricing = require './pricing'
es      = require './elasticsearch'
wayfair = require './wayfair'

utils   = require '../utils'

setProductTitleAndContent = (product_id, title, content) ->
  q = "UPDATE \"Products\" SET title = ?, content = ? WHERE id = ?"
  sequelize.query q, { type: sequelize.QueryTypes.UPDATE, replacements: [title, content, product_id] }

setSkuDimensionsForProduct = (product_id, length, width, height) ->
  q = "UPDATE \"Skus\" SET length = ?, width = ?, height = ? WHERE product_id = ?"
  sequelize.query q, { type: sequelize.QueryTypes.UPDATE, replacements: [length, width, height, product_id] }

setSkuDimensions = (id, length, width, height) ->
  q = "UPDATE \"Skus\" SET length = ?, width = ?, height = ? WHERE id = ?"
  sequelize.query q, { type: sequelize.QueryTypes.UPDATE, replacements: [length, width, height, id] }

updateIfDimensioned = (sku) ->
  return unless sku?.meta?.attributes?
  pairs = _.map sku.meta.attributes.split(/\|\|/g)
  attrs = {}
  for pair in pairs
    if pair.split(':=')[0] is 'Product1 D (in)' then sku.length = parseFloat(pair.split(':=')[1]) || null
    if pair.split(':=')[0] is 'Product1 W (in)' then sku.width  = parseFloat(pair.split(':=')[1]) || null
    if pair.split(':=')[0] is 'Product1 H (in)' then sku.height = parseFloat(pair.split(':=')[1]) || null
    if pair.split(':=')[0] is 'Dimensions'
      dimensions = pair.split(':=')[1].replace(/ /g,'').split('x')
      for dim in dimensions
        switch dim.slice(-1)
          when 'L' then sku.length = parseFloat(dim.slice(0,-1))
          when 'W', 'D' then sku.width = parseFloat(dim.slice(0,-1))
          when 'H' then sku.height = parseFloat(dim.slice(0,-1))
  if sku.length? or sku.width? or sku.height?
    setSkuDimensions sku.id, sku.length, sku.width, sku.height
  else
    Promise.resolve true

formTagTree = () ->
  # write tag tree to tree.txt
  tagText = ''
  tagTree = _.clone wayfair.tagTree
  flatTags = []
  for tag1 in Object.keys tagTree
    flatTags.push { tag: tag1, level: 1 }
    for tag2 in Object.keys(tagTree[tag1])
      flatTags.push { tag: tag2, level: 2 }
      for tag3 in tagTree[tag1][tag2]
        flatTags.push { tag: tag3, level: 3 }
  appendCount = (plaintextTag, level) ->
    urlTag = utils.tagText plaintextTag
    sku.countTagAtLevel urlTag, level
    .then (count) ->
      tagText += '\t'.repeat(level - 1) + plaintextTag + '\t'.repeat(3) + count + '\n'
  Promise.reduce flatTags, ((total, flatTag) -> appendCount(flatTag.tag, flatTag.level)), 0
  .then (res) ->
    fs.writeFileSync 'tree.xls', tagText

if argv.sku_dimensions
  ### coffee sku_processing/manual.coffee --sku_dimensions ###
  q = "SELECT id, meta FROM \"Skus\" WHERE length IS NULL AND width IS NULL AND height IS NULL AND meta IS NOT NULL"
  # q = "SELECT id, meta FROM \"Skus\" WHERE width IS NULL AND meta IS NOT NULL"
  sequelize.query q, { type: sequelize.QueryTypes.SELECT }
  .then (skus) ->
    console.log skus.length
    Promise.reduce skus, ((total, sku) -> updateIfDimensioned(sku)), 0
  .finally () -> process.exit()

else if argv.test_elasticsearch
  # Change es_index first
  ### coffee sku_processing/manual.coffee --test_elasticsearch ###
  es.deleteNestedIndex()
  .then () -> es.createNestedIndex()
  .then () -> es.bulkNestedIndex()
  .then (count) -> console.log 'count', count
  .catch (err) -> console.log 'err', err
  .finally () ->
    console.log 'finished'
    process.exit()

else if argv.form_tag_tree
  ### coffee sku_processing/manual.coffee --form_tag_tree ###
  formTagTree()
  .catch (err) -> console.log 'err', err
  .finally () ->
    console.log 'finished'
    process.exit()

else if argv.remove_tags
  ### coffee sku_processing/manual.coffee --remove_tags ###
  tagsToRemove = [
    'Home, garden & living'
    'Outdoor & sports'
    'Apparel, shoes & jewelry'
    'Kids, baby & toy'
    'Electronics & computer'
    # 'Home Accents'
    # 'Furniture'
    # 'Artwork'
    # 'Bed & Bath'
    # 'Kitchen'
    # 'Outdoor'
  ]
  skusToUpdate = []
  sku.findAll()
  .then (skus) ->
    for s in skus
      newTags = []
      for tag in s.tags
        newTags.push tag unless tagsToRemove.indexOf(tag) > -1
      if newTags.length > 0 and newTags.length isnt s.tags.length
        s.tags = newTags
        skusToUpdate.push s
    Promise.reduce skusToUpdate, ((total, s) -> sku.updateTags(s)), 0
  .then () -> console.log 'Updated ' + skusToUpdate.length + ' skus'
  .catch (err) -> console.log 'err', err
  .finally () ->
    console.log 'finished'
    process.exit()

else if argv.map_tags
  ### coffee sku_processing/manual.coffee --map_tags ###
  skus = []
  sku.findAll()
  .then (res) ->
    skus = res
    Promise.reduce skus, ((total, s) -> sku.processTagMap(s)), 0
  .then () -> console.log 'Updated ' + skus.length + ' skus'
  .catch (err) -> console.log 'err', err
  .finally () ->
    console.log 'finished'
    process.exit()

# else if argv.process_artwork_tags
#   ### coffee sku_processing/manual.coffee --process_artwork_tags ###
#   products = []
#   skus = []
#   sequelize.query 'SELECT id FROM "Products" WHERE category_id = 1', { type: sequelize.QueryTypes.SELECT }
#   .then (res) ->
#     products = res
#     ids = _.map products, 'id'
#     sequelize.query 'SELECT id, tags, tags1, tags2, tags3 FROM "Skus" WHERE product_id IN (' + ids.join(',') + ')', { type: sequelize.QueryTypes.SELECT }
#   .then (res) ->
#     skus = res
#     _.map skus, (s) -> s.tags3 = ['wall-art']
#     Promise.reduce skus, ((total, s) -> sku.updateTags(s)), 0
#   .then () -> console.log 'Updated ' + skus.length + ' skus'
#   .catch (err) -> console.log 'err', err
#   .finally () ->
#     console.log 'finished'
#     process.exit()
