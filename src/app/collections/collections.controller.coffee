'use strict'

angular.module('app.core').controller 'collectionsCtrl', (eeDefiner, eeCollections) ->

  collections = this

  collections.ee  = eeDefiner.exports
  collections.fns = eeCollections.fns

  eeCollections.fns.runQuery()

  return
