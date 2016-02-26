'use strict'

angular.module('app.core').factory 'eeTrack', ($rootScope, $q, eeAuth, eeBack) ->

  ## SETUP
  # none

  ## PRIVATE EXPORT DEFAULTS
  _data = {}

  ## PRIVATE FUNCTIONS
  _stripActivities = (track) ->
    ids = []
    for activity in track.activities
      if typeof activity is 'number' then ids.push(activity) else ids.push(activity.id)
    track.activities = ids

  _get = (id) ->
    eeBack.fns.trackGET id, eeAuth.fns.getToken()
    .then (track) -> track
    .catch (err) -> console.log err

  _update = (track) ->
    track.saved = false
    track.updating = true
    _stripActivities track
    eeBack.fns.trackPUT track, eeAuth.fns.getToken()
    .then (tr) ->
      track[prop] = tr[prop] for prop in ['title', 'icon', 'activities', 'type', 'title_for_unassigned', 'show']
      $rootScope.$broadcast 'track:updated', track
      track
    .catch (err) -> track.err = err
    .finally () -> track.updating = false

  ## EXPORTS
  data: _data
  fns:
    get: _get
    update: _update
