'use strict'

angular.module('app.core').factory 'eeActivity', ($rootScope, $q, eeAuth, eeBack) ->

  ## SETUP
  # none

  ## PRIVATE EXPORT DEFAULTS
  _data = {}

  ## PRIVATE FUNCTIONS
  _create = (activity) ->
    eeBack.fns.activityPOST activity, eeAuth.fns.getToken()

  _update = (activity) ->
    activity.saved = false
    activity.updating = true
    eeBack.fns.activityPUT activity, eeAuth.fns.getToken()
    .then (act) ->
      activity[prop] = act[prop] for prop in ['title', 'html', 'track', 'show']
      $rootScope.$broadcast 'activity:updated', activity
      activity
    .catch (err) -> activity.err = err
    .finally () -> activity.updating = false

  ## EXPORTS
  data: _data
  fns:
    create: _create
    update: _update
