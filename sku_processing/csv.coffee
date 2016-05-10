_         = require 'lodash'
Promise   = require 'bluebird'
parse     = require 'csv-parse'

utils     = require '../utils'
mappings  = require './doba.mappings'

csv = {}

# getRows = (path) ->
#   new Promise (resolve, reject) ->
#     fs.readFile path, 'utf-8', (err, data) ->
#       if err then reject err
#       parse data, {}, (err, rows) ->
#         if err then reject err
#         rows.shift()
#         resolve rows

csv.parseSkuCreateFile = (data, category_id) ->
  throw 'parseSkuCreateFile missing category_id' unless category_id?
  # Read csv and return array of objects:
  # {
  #   sku: {
  #     identifier
  #     msrp
  #     selection_text
  #     quantity
  #     discontinued
  #     supplier_id
  #     supplier_name
  #     manufacturer_name
  #     brand_name
  #     supply_shipping_price
  #     supply_price
  #     meta: {}
  #     other: {}
  #   },
  #   product: {
  #     title
  #     content
  #     external_identity -> 'DOBA.' + product_id
  #     image
  #     additional_images: []
  #     category_id
  #   }
  # }
  new Promise (resolve, reject) ->
    parse data, {}, (err, rows) ->
      if err then reject err
      columns = rows.shift()
      sku_attrs = [
        'item_sku'
        'msrp'
        'item_name'
        'qty_avail'
        'stock'
        'supplier_id'
        'supplier_name'
        'manufacturer'
        'brand_name'
        'ship_cost'
        'price'
        # meta
        'warranty'
        'condition'
        'ship_weight'
        'attributes'
        # other
        'product_id'
        'product_sku'
        'product_last_update'
        'item_id'
        'upc'
        'item_last_update'
        'categories'
        'image_file'
        'additional_images'
      ]
      product_attrs = [
        'title'
        'description'
        'product_id' # 'DOBA.' + product_id
        'image_file'
        'additional_images'
        # category_id added manually
      ]
      sku_indices = {}
      sku_indices[attr] = columns.indexOf(attr) for attr in sku_attrs
      product_indices = {}
      product_indices[attr] = columns.indexOf(attr) for attr in product_attrs
      parsed_rows = []
      for row in rows
        sku =
          meta: {}
          other: {}
        product = {}
        # Handle sku
        for attr in sku_attrs
          if mappings.sku[attr].indexOf('meta.') is 0
            sku.meta[mappings.sku[attr].replace('meta.','')] = row[sku_indices[attr]]
          else if mappings.sku[attr].indexOf('other.') is 0
            sku.other[mappings.sku[attr].replace('other.','')] = row[sku_indices[attr]]
          else
            sku[mappings.sku[attr]] = row[sku_indices[attr]]
        sku.discontinued = (sku.discontinued is 'discontinued')
        sku[attr] = utils.dollarsToCents(sku[attr]) for attr in ['supply_price', 'supply_shipping_price', 'msrp']
        sku.quantity = parseInt sku.quantity
        # Handle product
        for attr in product_attrs
          product[mappings.product[attr]] = row[product_indices[attr]]
        product.category_id = category_id
        product.external_identity = 'DOBA.' + product.external_identity
        product.additional_images = if product.additional_images isnt '' then product.additional_images.split('|') else []
        parsed_rows.push { sku: sku, product: product }
      resolve parsed_rows

csv.parseSkuPricingFile = (data) ->
  # Read csv and return array of objects:
  # {
  #   identifier
  #   supplier_id
  #   supply_shipping_price
  #   supply_price
  #   quantity
  #   msrp
  #   discontinued
  # }
  new Promise (resolve, reject) ->
    parse data, {}, (err, rows) ->
      if err then reject err
      columns = rows.shift()
      attrs = ['item_sku', 'supplier_id', 'ship_cost', 'price', 'qty_avail', 'msrp', 'stock']
      indices = {}
      indices[attr] = columns.indexOf(attr) for attr in attrs
      parsed_rows = []
      for row in rows
        parsed_row = {}
        parsed_row[mappings.sku[attr]] = row[indices[attr]] for attr in attrs
        if parsed_row.discontinued then parsed_row.discontinued = (parsed_row.discontinued is 'discontinued')
        parsed_row[attr] = utils.dollarsToCents(parsed_row[attr]) for attr in ['supply_price', 'supply_shipping_price', 'msrp']
        parsed_row.quantity = parseInt parsed_row.quantity
        parsed_rows.push parsed_row
      resolve parsed_rows

csv.parseSkuSelectionTextFile = (data) ->
  # Read csv and return array of objects:
  # {
  #   id (sku)
  #   selection_text
  # }
  new Promise (resolve, reject) ->
    parse data, {}, (err, rows) ->
      if err then reject err
      columns = rows.shift()
      parsed_rows = []
      for row in rows
        parsed_row =
          id: parseInt(row[0])
          selection_text: row[1]
        parsed_rows.push parsed_row
      resolve parsed_rows

csv.parseProductTitleAndContentFile = (data) ->
  # Read csv and return array of objects:
  # {
  #   id (product)
  #   title
  #   content
  # }
  new Promise (resolve, reject) ->
    parse data, {}, (err, rows) ->
      if err then reject err
      columns = rows.shift()
      parsed_rows = []
      for row in rows
        parsed_row =
          id: parseInt(row[0])
          title: row[1]
          content: row[2]
        parsed_rows.push parsed_row
      resolve parsed_rows

module.exports = csv
