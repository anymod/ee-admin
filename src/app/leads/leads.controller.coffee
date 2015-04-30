'use strict'

angular.module('app.core').controller 'leadsCtrl', ($rootScope, eeDefiner, eeAuth, eeBack, eeLeads) ->

  this.ee   = eeDefiner.exports
  this.data = eeLeads.data
  this.fns  = eeLeads.fns
  that = this

  eeLeads.fns.search()

  this.copyToNav = (url) ->
    $rootScope.navUrl = url

  return
