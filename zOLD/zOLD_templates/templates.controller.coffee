'use strict'

angular.module('app.core').controller 'templatesCtrl', (eeDefiner, eeProducts, eeTaxonomies) ->

  templates = this

  templates.compact    = true
  templates.hideHidden = true

  templates.ee   = eeDefiner.exports
  templates.data = eeProducts.data
  templates.fns  = eeProducts.fns
  templates.taxonomyData = eeTaxonomies.data

  eeProducts.fns.search()
  eeTaxonomies.fns.search()

  return
