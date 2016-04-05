_         = require 'lodash'
Promise   = require 'bluebird'
parse     = require 'csv-parse'

utils     = require '../utils'
mappings  = require './doba.mappings'

csv = {}

csv.parseFile = (data) ->
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
        parsed_row[attr] = csv.dollarsToCents(parsed_row[attr]) for attr in ['supply_price', 'supply_shipping_price', 'msrp']
        parsed_row.quantity = parseInt parsed_row.quantity
        parsed_rows.push parsed_row
      resolve parsed_rows

csv.addDateToFilename = (filename) ->
  splitAt   = filename.lastIndexOf('.')
  name      = filename.substring(0, splitAt)
  extension = filename.substring(splitAt)
  dateNow = new Date()
  name + '_processed-' + utils.fileTimestamp() + extension

csv.dollarsToCents = (dollars) ->
  dollars = parseFloat dollars
  parseInt(dollars * 100)

module.exports = csv
