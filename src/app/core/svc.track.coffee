'use strict'

angular.module('app.core').factory 'eeTrack', ($q, eeAuth, eeBack) ->

  ## SETUP
  # none

  ## PRIVATE EXPORT DEFAULTS
  _data = {}

  ## PRIVATE FUNCTIONS
  _get = (id) ->
    eeBack.fns.trackGET id, eeAuth.fns.getToken()
    .then (track) -> track
    .catch (err) -> console.log err
    # .finally () -> product.updating = false

  ## EXPORTS
  data: _data
  fns:
    get: _get
