'use strict'

angular.module('app.core').controller 'templatesCtrl', (eeDefiner, eeCatalog, eeTaxonomies) ->

  templates = this

  templates.compact    = true
  templates.hideHidden = true

  templates.ee   = eeDefiner.exports
  templates.data = eeCatalog.data
  templates.fns  = eeCatalog.fns
  templates.taxonomyData = eeTaxonomies.data

  eeCatalog.fns.search()
  eeTaxonomies.fns.search()

  return
