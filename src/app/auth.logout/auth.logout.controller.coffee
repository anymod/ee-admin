'use strict'

angular.module('admin.auth').controller 'logoutCtrl', (eeAuth) ->
  eeAuth.fns.logout()
  return
