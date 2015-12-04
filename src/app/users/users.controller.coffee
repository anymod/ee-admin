'use strict'

angular.module('app.core').controller 'usersCtrl', ($state, eeUsers) ->

  users = this
  users.data  = eeUsers.data
  users.fns   = eeUsers.fns

  users.state = $state

  eeUsers.fns.search()

  return
