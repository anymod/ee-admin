'use strict'

angular.module('app.core').controller 'userCtrl', ($rootScope, $stateParams, $scope, eeUser) ->

  user = this
  user.id = $stateParams.id

  user.reading = true
  eeUser.fns.get user.id
  .then (res) -> user.user = res
  .finally () -> user.reading = false

  return
