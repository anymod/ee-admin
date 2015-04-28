'use strict'

angular.module('app.core').controller 'productsCtrl', (eeDefiner, eeCatalog) ->

  this.ee = eeDefiner.exports

  this.data       = eeCatalog.data
  this.fns        = eeCatalog.fns
  # this.productFns = eeProduct.fns
  # this.storeFns   = eeStorefront.fns
  #
  eeCatalog.fns.search()

  return
