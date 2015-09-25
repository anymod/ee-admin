'use strict'

angular.module('app.core').controller 'taxonomiesCtrl', (eeDefiner, eeTaxonomies) ->

  taxonomies = this

  taxonomies.ee   = eeDefiner.exports
  taxonomies.data = eeTaxonomies.data

  taxonomies.attributes = ['style', 'color', 'material']

  resetVals = () ->
    taxonomies.vals =
      style: ''
      color: ''
      material: ''

  taxonomies.create = (attr, val) ->
    eeTaxonomies.fns.createTaxonomy attr, val
    .then () -> resetVals()

  taxonomies.delete = (taxonomy) -> eeTaxonomies.fns.destroyTaxonomy taxonomy

  eeTaxonomies.fns.search()

  return
