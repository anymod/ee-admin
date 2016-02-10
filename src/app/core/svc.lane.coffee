'use strict'

angular.module('app.core').factory 'eeLane', ($rootScope, $q, eeAuth, eeBack) ->

  ## SETUP
  # none

  ## PRIVATE EXPORT DEFAULTS
  _data = {}

  ## PRIVATE FUNCTIONS
  _stripActivities = (lane) ->
    ids = []
    for activity in lane.activities
      if typeof activity is 'number' then ids.push(activity) else ids.push(activity.id)
    lane.activities = ids

  _create = (lane) ->
    eeBack.fns.lanePOST lane, eeAuth.fns.getToken()

  _update = (lane) ->
    lane.saved = false
    lane.updating = true
    _stripActivities lane
    eeBack.fns.lanePUT lane, eeAuth.fns.getToken()
    .then (ln) ->
      lane[prop] = ln[prop] for prop in ['title', 'activities', 'intro', 'show']
      $rootScope.$broadcast 'lane:updated', lane
      lane
    .catch (err) -> lane.err = err
    .finally () -> lane.updating = false

  ## EXPORTS
  data: _data
  fns:
    create: _create
    update: _update
