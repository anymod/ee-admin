_       = require 'lodash'
Promise = require 'bluebird'
argv    = require('yargs').argv

utils   = require '../utils'
sku     = require './sku'

fns = {}

# Tables at https://docs.google.com/spreadsheets/d/1XEk89Wed2cpsS5NY6FryX0GvYFSxPLq6eWO3I6FQBgw/edit#gid=0

shippingTable = [
  # rows are regular_price
  # columns are supply_shipping_price
  [ 0, 299, 399, 499, 'discontinue', 'discontinue' ]
  [ 0, 399, 499, 799, 'discontinue', 'discontinue' ]
  [ 0, 499, 799, 999, 1499, 'discontinue' ]
  [ 0, 0, 0, 0, 0, 0 ]
  [ 0, 0, 0, 0, 0, 0 ]
]

earningsTable = [ 0.20, 0.15, 0.10, 0.07, 0.05 ]

getShippingTableRow = (regular_price) ->
  for max, i in [1000, 2500, 5000, 10000, 10000000]
    if regular_price < max then return i
  return 'not found'

getShippingTableColumn = (supply_shipping_price) ->
  for max, i in [1, 500, 1500, 2500, 5000, 10000000]
    if supply_shipping_price < max then return i
  return 'not found'

getEarningsTableRow = (regular_price) ->
  return 'discontinue' if regular_price < 100
  for max, i in [2500, 5000, 10000, 20000, 10000000]
    if regular_price < max then return i
  return 'not found'

fns.shippingPriceLookup = (regular_price, supply_shipping_price) ->
  return undefined unless regular_price? and supply_shipping_price?
  row = getShippingTableRow regular_price
  col = getShippingTableColumn supply_shipping_price
  shippingTable[row][col]

fns.shippingPriceGuess = (supply_price, supply_shipping_price) ->
  fns.shippingPriceLookup (supply_price + supply_shipping_price), supply_shipping_price

fns.getBaselinePrice = (supply_price, supply_shipping_price, shipping_price) ->
  shipping_price = fns.shippingPriceGuess(supply_price, supply_shipping_price) unless shipping_price?
  supply_price + supply_shipping_price - shipping_price

fns.getRegularPrice = (baseline_price) ->
  marginGuess = earningsTable[getEarningsTableRow(baseline_price)]
  regularPriceGuess = baseline_price / (1 - marginGuess)
  margin = earningsTable[getEarningsTableRow(regularPriceGuess)]
  unroundedRegularPrice = parseInt(baseline_price / (1 - margin))
  unroundedRegularPrice - (unroundedRegularPrice % 100) + 99

fns.getValues = (supply_price, supply_shipping_price) ->
  # baseline_price, regular_price, shipping_price
  shipping_price = fns.shippingPriceGuess(supply_price, supply_shipping_price)
  baseline_price = fns.getBaselinePrice(supply_price, supply_shipping_price, shipping_price)
  regular_price  = fns.getRegularPrice(baseline_price)
  shipping_price = fns.shippingPriceLookup(regular_price, supply_shipping_price)
  {
    baseline_price: baseline_price
    regular_price:  regular_price
    shipping_price: shipping_price
  }

module.exports = fns
