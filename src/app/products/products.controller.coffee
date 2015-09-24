'use strict'

angular.module('app.core').controller 'productsCtrl', (eeDefiner, eeAuth, eeBack, eeCatalog, eeModal) ->

  products = this

  products.ee   = eeDefiner.exports
  products.data = eeCatalog.data
  products.fns  = eeCatalog.fns

  # products.hide = (product) ->
  #   product.loading = true
  #   eeBack.productPUT { id: product.id, hide_from_catalog: true }, eeAuth.fns.getToken()
  #   .then (prod) -> product.hide_from_catalog = prod.hide_from_catalog
  #   .catch (err) -> console.error err
  #   .finally () ->  product.loading = false
  #
  # products.unhide = (product) ->
  #   product.loading = true
  #   eeBack.productPUT { id: product.id, hide_from_catalog: false }, eeAuth.fns.getToken()
  #   .then (prod) -> product.hide_from_catalog = prod.hide_from_catalog
  #   .catch (err) -> console.error err
  #   .finally () ->  product.loading = false

  # products.open = (product) ->
  #   eeBack.productGET product.id, eeAuth.fns.getToken()
  #   .then (prod) -> eeModal.fns.openProductModal prod
  #   .catch (err) -> console.error err
  #   .finally () ->  product.loading = false

  eeCatalog.fns.search()

  return
