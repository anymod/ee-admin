_         = require 'lodash'
Promise   = require 'bluebird'
sequelize = require '../config/sequelize/setup'
argv      = require('yargs').argv

sku     = require './sku'
pricing = require './pricing'

utils   = require '../utils'

setProductTitleAndContent = (product_id, title, content) ->
  q = "UPDATE \"Products\" SET title = ?, content = ? WHERE id = ?"
  sequelize.query q, { type: sequelize.QueryTypes.UPDATE, replacements: [title, content, product_id] }

setSkuDimensionsForProduct = (product_id, length, width, height) ->
  q = "UPDATE \"Skus\" SET length = ?, width = ?, height = ? WHERE product_id = ?"
  sequelize.query q, { type: sequelize.QueryTypes.UPDATE, replacements: [length, width, height, product_id] }

if argv.bedding_vermicelli
  ### coffee sku_processing/manual.coffee --bedding_vermicelli ###
  product_count = 0
  # SELECT count(*) from "Skus" WHERE selection_text ilike '%quilt%' AND length is null; 93
  # SELECT count(*) from "Skus" WHERE selection_text ilike '%blanket%' AND length is null; 130
  # SELECT count(*) from "Skus" WHERE selection_text ilike '%throw%' AND length is null; 120
  # SELECT count(*) from "Skus" WHERE selection_text ilike '%throw blanket%' AND length is null; 93
  # SELECT count(*) from "Skus" WHERE selection_text ilike '%comforter%' AND length is null; 150
  q = "SELECT id, title, content FROM \"Products\" WHERE title ilike '[%' AND title ilike '%3PC Vermicelli%' AND title ilike '%Queen%'"
  sequelize.query q, { type: sequelize.QueryTypes.SELECT }
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

else if argv.onitiva
  ### coffee sku_processing/manual.coffee --onitiva ###
  product_count = 0
  # SELECT count(*) from "Products" WHERE title ilike '%onitiva%' and title ilike '%throw%' AND title ilike '%78.7%';
  # SELECT id, title from "Products" WHERE title ilike '%onitiva%' and title ilike '%floor cushion%' AND title ilike '%19.7%';
  q1 = "SELECT id, title from \"Products\" WHERE title ilike '%onitiva%' AND title ilike '%throw%' AND title ilike '%78.7%'" # 57
  q2 = "SELECT id, title from \"Products\" WHERE title ilike '%onitiva%' AND title ilike '%throw%' AND title ilike '%86.6%'" # 14
  q3 = "SELECT id, title from \"Products\" WHERE title ilike '%onitiva%' AND title ilike '%floor cushion%' AND title ilike '%19.7%'" # 50

  sequelize.query q1, { type: sequelize.QueryTypes.SELECT }
  .then (products) ->
    product_count += products.length
    updateProduct1 = (prod) ->
      style = prod.title.match(/\[.*\]/g)[0].replace(/[\[\]]/g,'')
      title = style + ' Throw Blanket'
      content = 'This blanket measures 59 by 78.7 inches. Suitable for home or travel. Soft materials and high tenacity; Fine and concentrated stitches; Machine washable and dryable. Exquisitely soft, and effortlessly warm! You have to feel this throw to believe the softness. Front: 100% Coral Fleece, Back: Plush. Fashionable and elegant blanket, perfect for your bedroom.\n\nThis Patchwork Throw Blanket measures 59 by 78.7 inches. Comfort, warmth and stylish designs. Whether you are adding the final touch to your bedroom or rec-room these patterns will add a little whimsy to your decor. This Coral Fleece Patchwork throw blanket will make a fun additional to any room and are beautiful draped over a sofa, chair, bottom of your bed and handy to grab and snuggle up in when there is a chill in the air. They are the perfect gift for any occasion! Keep one in your car for staying warm at outdoor sporting events. Place one on your couch or favorite upholstered chair. Have extras on hand for sleepovers and overnight guests. Machine wash and tumble dry for easy care. Will look and feel as good as new after multiple washings!'
      setProductTitleAndContent prod.id, title, content
      .then () -> setSkuDimensionsForProduct prod.id, 78.7, 59, null
    Promise.reduce products, ((total, product) -> updateProduct1(product)), 0
  .then () ->
    sequelize.query q2, { type: sequelize.QueryTypes.SELECT }
  .then (products) ->
    product_count += products.length
    updateProduct2 = (prod) ->
      style = prod.title.match(/\[.*\]/g)[0].replace(/[\[\]]/g,'')
      title = style + ' Throw Blanket'
      content = 'This blanket measures 61 by 86.6 inches. Suitable for home or travel. Soft materials and high tenacity; Fine and concentrated stitches; Machine washable and dryable. Exquisitely soft, and effortlessly warm! You have to feel this throw to believe the softness. Front: 100% Coral Fleece, Back: Plush. Fashionable and elegant blanket, perfect for your bedroom.\n\nThis Throw Blanket measures 61 by 86.6 inches. Comfort, warmth and stylish designs. Whether you are adding the final touch to your bedroom or rec-room these patterns will add a little whimsy to your decor. This Coral Fleece Patchwork throw blanket will make a fun additional to any room and are beautiful draped over a sofa, chair, bottom of your bed and handy to grab and snuggle up in when there is a chill in the air. They are the perfect gift for any occasion! Keep one in your car for staying warm at outdoor sporting events. Place one on your couch or favorite upholstered chair. Have extras on hand for sleepovers and overnight guests. Machine wash and tumble dry for easy care. Will look and feel as good as new after multiple washings!'
      setProductTitleAndContent prod.id, title, content
      .then () -> setSkuDimensionsForProduct prod.id, 78.7, 59, null
    Promise.reduce products, ((total, product) -> updateProduct2(product)), 0
  .then () ->
    sequelize.query q3, { type: sequelize.QueryTypes.SELECT }
  .then (products) ->
    product_count += products.length
    updateProduct3 = (prod) ->
      style = prod.title.match(/\[.*\]/g)[0].replace(/[\[\]]/g,'')
      title = style + ' Pillow Cushion'
      content = 'This stylish decorative pillow measures 19.7 by 19.7 inches with creative design pattern.\n\nAesthetics and Functionality Combined. Hug and wrap your arms around this stylish decorative pillow measuring 19.7 by 19.7 inches, offering a sense of warmth and comfort to home and outdoor alike. Find a friend in its team of skilled and creative designers as they seek to use materials only of the highest quality. This art pillow by Onitiva features contemporary design, modern elegance and fine construction. The pillow is made to have invisible zippers and fill-down alternative. The rich look and feel, extraordinary textures and vivid colors of this comfy pillow transforms an ordinary, dull room into an exciting and luxurious place for rest and recreation. Suitable for your living room, bedroom, office and patio. It will surely add a touch of life, variety and magic to any rooms in your home. The pillow has a hidden side zipper to remove the center fill for easy washing of the cover if needed.'
      setProductTitleAndContent prod.id, title, content
      .then () -> setSkuDimensionsForProduct prod.id, 19.7, 19.7, null
    Promise.reduce products, ((total, product) -> updateProduct3(product)), 0
  .then (res) ->  console.log 'finished ' + product_count + ' products'
  .catch (err) -> console.log 'err', err
  .finally () -> process.exit()
