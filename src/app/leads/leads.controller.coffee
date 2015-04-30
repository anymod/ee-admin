'use strict'

angular.module('app.core').controller 'leadsCtrl', ($rootScope, eeDefiner, eeAuth, eeBack) ->

  this.ee = eeDefiner.exports
  that = this

  eeBack.leadsGET eeAuth.fns.getToken()
  .then (leads) -> that.leads = leads
  .catch (err) -> console.error err

  this.copyToNav = (url) ->
    $rootScope.navUrl = url

  return
