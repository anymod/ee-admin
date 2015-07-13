'use strict'

angular.module('app.core').controller 'usersCtrl', (eeUsers) ->

  users = this
  users.data = eeUsers.data

  users.fns = eeUsers.fns

  eeUsers.fns.search()

  return
