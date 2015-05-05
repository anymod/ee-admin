'use strict'

angular.module('app.core').controller 'leadsCtrl', ($rootScope, eeDefiner, eeAuth, eeBack, eeLeads) ->

  that      = this
  this.ee   = eeDefiner.exports
  this.data = eeLeads.data
  this.fns  = eeLeads.fns

  this.copyToNav = (url) -> $rootScope.navUrl = url

  eeLeads.fns.search()

  return
