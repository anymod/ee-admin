'use strict'

angular.module('app.core').factory 'eeUser', ($q, eeAuth, eeBack) ->

  ## SETUP
  # none

  ## PRIVATE EXPORT DEFAULTS
  _data = {}

  ## PRIVATE FUNCTIONS
  _get = (id) ->
    eeBack.fns.userGET id, eeAuth.fns.getToken()
    .then (user) -> user
    .catch (err) -> console.log err
    # .finally () -> product.updating = false

  ## EXPORTS
  data: _data
  fns:
    get: _get
