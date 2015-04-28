'use strict'

angular.module('app.core').filter 'eeShopCategories', () ->
  (products, category) ->
    if !products or !category or category is 'All' then return products
    filtered = []
    for product in products
      # TODO implement custom categories
      # if product.categories?.indexOf(category) >= 0 then filtered.push product
      if product.category is category then filtered.push product
    return filtered

angular.module('app.core').filter 'centToDollar', ($filter) ->
  (cents) ->
    currencyFilter = $filter('currency')
    currencyFilter Math.floor(cents)/100

angular.module('app.core').filter 'thumbnail', () ->
  (url) ->
    if !!url and url.indexOf("image/upload") > -1
      url.split("image/upload").join('image/upload/c_pad,w_150,h_150')
    else
      url

angular.module('app.core').filter 'mainImg', () ->
  (url) ->
    if !!url and url.indexOf("image/upload") > -1
      url.split("image/upload").join('image/upload/c_limit,w_500,h_500')
    else
      url

angular.module('app.core').filter 'scaledDownBackground', () ->
  (url) ->
    if !!url and url.indexOf("h_400,w_1200") > -1
      url.replace('h_400,w_1200', 'h_133,w_400')
    else
      url

angular.module('app.core').filter 'urlText', () ->
  (text) -> text.replace(/[^a-zA-Z0-9-]|^-/gi, '').toLowerCase()

angular.module('app.core').filter 'unboldHtml', () ->
  (text) -> if typeof text isnt 'string' then return text else return text.replace(/<b>/gi, '').replace(/<\/b>/gi, '')

angular.module('app.core').filter 'truncateQty', () ->
  (text) -> if parseInt(text) > 20 then return '20+' else return text

angular.module('app.core').filter 'rangeToText', () ->
  (range) ->
    if !range?.min and !range?.max then return 'Prices'
    ('$' + Math.floor(range.min)/100 + ' to $' + Math.floor(range.max)/100)
      .replace '$0 to', 'Under'
      .replace 'to $0', 'and above'

angular.module('app.core').filter 'addHttp', () ->
  (text) -> if !!text and text.indexOf('http://') isnt 0 and text.indexOf('https://') isnt 0 then 'http://' + text else text
