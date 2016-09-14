'use strict'

angular.module('app.core').factory 'eeProduct', ($q, eeAuth, eeBack) ->

  ## SETUP
  # none

  ## PRIVATE EXPORT DEFAULTS
  _data = {}

  ## PRIVATE FUNCTIONS
  _filterAttrs = (product, attrs, sku_attrs) ->
    attrs ||= []
    sku_attrs ||= []
    return product unless attrs.length > 0 or sku_attrs.length > 0
    for attr in Object.keys(product)
      delete product[attr] if attr isnt 'skus' and attr isnt 'id' and attr isnt 'category_id' and attrs.indexOf(attr) < 0
    if sku_attrs and product.skus and product.skus.length > 0
      for sku, i in product.skus
        for sku_attr in Object.keys(product.skus[i])
          delete sku[sku_attr] if sku_attr isnt 'id' and sku_attr isnt 'product_id' and sku_attrs.indexOf(sku_attr) < 0
    product

  _update = (product, attrs, sku_attrs) ->
    product.saved = false
    product.updating = true
    _filterAttrs product, attrs, sku_attrs
    eeBack.fns.productPUT product, eeAuth.fns.getToken()
    .then (prod) ->
      product.title   = prod.title
      product.content = prod.content
      product.skus    = prod.skus
      product.saved   = true
      prod
    .catch (err) -> product.err = err
    .finally () -> product.updating = false


  ## EXPORTS
  data: _data
  fns:
    update: _update
