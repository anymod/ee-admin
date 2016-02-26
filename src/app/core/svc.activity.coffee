'use strict'

angular.module('app.core').factory 'eeActivity', ($rootScope, $q, eeAuth, eeBack) ->

  ## SETUP
  # none

  ## PRIVATE EXPORT DEFAULTS
  _data = {}

  ## PRIVATE FUNCTIONS
  _stripSteps = (activity) ->
    ids = []
    for step in activity.steps
      if typeof step is 'number' then ids.push(step) else ids.push(step.id)
    activity.steps = ids

  _create = (activity) ->
    eeBack.fns.activityPOST activity, eeAuth.fns.getToken()

  _update = (activity) ->
    activity.saved = false
    activity.updating = true
    _stripSteps activity
    eeBack.fns.activityPUT activity, eeAuth.fns.getToken()
    .then (ln) ->
      activity[prop] = ln[prop] for prop in ['title', 'steps', 'intro', 'show']
      $rootScope.$broadcast 'activity:updated', activity
      activity
    .catch (err) -> activity.err = err
    .finally () -> activity.updating = false

  ## EXPORTS
  data: _data
  fns:
    create: _create
    update: _update
