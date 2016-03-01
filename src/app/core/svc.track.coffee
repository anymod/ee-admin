'use strict'

angular.module('app.core').factory 'eeTrack', ($rootScope, $q, eeAuth, eeBack) ->

  ## SETUP
  # none

  ## PRIVATE EXPORT DEFAULTS
  _data = {}

  ## PRIVATE FUNCTIONS
  _stripActivities = (track) ->
    activity_ids = []
    guide_ids = []
    for activity in track.activities
      if typeof activity is 'number' then activity_ids.push(activity) else activity_ids.push(activity.id)
    for activity in track.guides
      if typeof activity is 'number' then guide_ids.push(activity) else guide_ids.push(activity.id)
    track.activities = activity_ids
    track.guides = guide_ids

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
      track[prop] = tr[prop] for prop in ['title', 'icon', 'activities', 'guides', 'type', 'title_for_unassigned', 'show']
      $rootScope.$broadcast 'track:updated', track
      track
    .catch (err) -> track.err = err
    .finally () -> track.updating = false

  ## EXPORTS
  data: _data
  fns:
    get: _get
    update: _update
