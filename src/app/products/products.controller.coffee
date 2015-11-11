'use strict'

angular.module('app.core').controller 'productsCtrl', (eeDefiner, eeProducts, eeTaxonomies) ->

  products = this

  products.compact    = true
  products.hideHidden = true

  products.ee   = eeDefiner.exports
  products.data = eeProducts.data
  products.fns  = eeProducts.fns
  products.taxonomyData = eeTaxonomies.data

  eeProducts.fns.search()
  eeTaxonomies.fns.search()

  return
