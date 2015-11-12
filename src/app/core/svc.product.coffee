'use strict'

angular.module('app.core').factory 'eeProduct', ($q, eeAuth, eeBack) ->

  ## SETUP
  # none

  ## PRIVATE EXPORT DEFAULTS
  _data = {}

  ## PRIVATE FUNCTIONS
  _update = (product) ->
    product.updating = true
    eeBack.fns.productPUT product, eeAuth.fns.getToken()
    .then (prod) ->
      product.title = prod.title
      product.content = prod.content
      product.skus = prod.skus
    .catch (err) -> product.err = err
    .finally () -> product.updating = false


  ## EXPORTS
  data: _data
  fns:
    update: _update
