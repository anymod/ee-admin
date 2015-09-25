'use strict'

angular.module('app.core').controller 'productsCtrl', (eeDefiner, eeCatalog, eeTaxonomies) ->

  products = this

  products.compact    = true
  products.hideHidden = true

  products.ee   = eeDefiner.exports
  products.data = eeCatalog.data
  products.fns  = eeCatalog.fns
  products.taxonomyData = eeTaxonomies.data

  eeCatalog.fns.search()
  eeTaxonomies.fns.search()

  return
