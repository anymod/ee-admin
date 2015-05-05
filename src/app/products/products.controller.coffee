'use strict'

angular.module('app.core').controller 'productsCtrl', (eeDefiner, eeAuth, eeBack, eeCatalog, eeModal) ->

  this.ee   = eeDefiner.exports
  this.data = eeCatalog.data
  this.fns  = eeCatalog.fns

  this.hide = (product) ->
    product.loading = true
    eeBack.productPUT { id: product.id, hide_from_catalog: true }, eeAuth.fns.getToken()
    .then (prod) -> product.hide_from_catalog = prod.hide_from_catalog
    .catch (err) -> console.error err
    .finally () ->  product.loading = false

  this.unhide = (product) ->
    product.loading = true
    eeBack.productPUT { id: product.id, hide_from_catalog: false }, eeAuth.fns.getToken()
    .then (prod) -> product.hide_from_catalog = prod.hide_from_catalog
    .catch (err) -> console.error err
    .finally () ->  product.loading = false

  this.open = (product) ->
    eeBack.productGET product.id, eeAuth.fns.getToken()
    .then (prod) -> eeModal.fns.openProductModal prod
    .catch (err) -> console.error err
    .finally () ->  product.loading = false


  eeCatalog.fns.search()

  return
