'use strict'

angular.module('app.core').factory 'eeTrack', ($rootScope, $q, eeAuth, eeBack) ->

  ## SETUP
  # none

  ## PRIVATE EXPORT DEFAULTS
  _data = {}

  ## PRIVATE FUNCTIONS
  _stripLanes = (track) ->
    ids = []
    for lane in track.lanes
      if typeof lane is 'number' then ids.push(lane) else ids.push(lane.id)
    track.lanes = ids

  _get = (id) ->
    eeBack.fns.trackGET id, eeAuth.fns.getToken()
    .then (track) -> track
    .catch (err) -> console.log err

  _update = (track) ->
    track.saved = false
    track.updating = true
    _stripLanes track
    eeBack.fns.trackPUT track, eeAuth.fns.getToken()
    .then (tr) ->
      track[prop] = tr[prop] for prop in ['title', 'icon', 'lanes', 'type', 'last_lane_name', 'show']
      $rootScope.$broadcast 'track:updated', track
      track
    .catch (err) -> track.err = err
    .finally () -> track.updating = false

  ## EXPORTS
  data: _data
  fns:
    get: _get
    update: _update
