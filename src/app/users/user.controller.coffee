'use strict'

angular.module('app.core').controller 'userCtrl', ($state, eeUser) ->

  user = this

  # TODO implement /admin/users/:id on ee-back
  eeUser.fns.get(49)
  .then (res) -> console.log res

  return
