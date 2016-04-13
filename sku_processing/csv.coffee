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
