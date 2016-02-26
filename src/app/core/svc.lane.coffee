'use strict'

angular.module('app.core').factory 'eeLane', ($rootScope, $q, eeAuth, eeBack) ->

  ## SETUP
  # none

  ## PRIVATE EXPORT DEFAULTS
  _data = {}

  ## PRIVATE FUNCTIONS
  _stripSteps = (lane) ->
    ids = []
    for step in lane.steps
      if typeof step is 'number' then ids.push(step) else ids.push(step.id)
    lane.steps = ids

  _create = (lane) ->
    eeBack.fns.lanePOST lane, eeAuth.fns.getToken()

  _update = (lane) ->
    lane.saved = false
    lane.updating = true
    _stripSteps lane
    eeBack.fns.lanePUT lane, eeAuth.fns.getToken()
    .then (ln) ->
      lane[prop] = ln[prop] for prop in ['title', 'steps', 'intro', 'show']
      $rootScope.$broadcast 'lane:updated', lane
      lane
    .catch (err) -> lane.err = err
    .finally () -> lane.updating = false

  ## EXPORTS
  data: _data
  fns:
    create: _create
    update: _update
