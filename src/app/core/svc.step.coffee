'use strict'

angular.module('app.core').factory 'eeStep', ($rootScope, $q, eeAuth, eeBack) ->

  ## SETUP
  # none

  ## PRIVATE EXPORT DEFAULTS
  _data = {}

  ## PRIVATE FUNCTIONS
  _create = (step) ->
    eeBack.fns.stepPOST step, eeAuth.fns.getToken()

  _update = (step) ->
    step.saved = false
    step.updating = true
    eeBack.fns.stepPUT step, eeAuth.fns.getToken()
    .then (act) ->
      step[prop] = act[prop] for prop in ['title', 'html', 'track', 'show']
      $rootScope.$broadcast 'step:updated', step
      step
    .catch (err) -> step.err = err
    .finally () -> step.updating = false

  ## EXPORTS
  data: _data
  fns:
    create: _create
    update: _update
