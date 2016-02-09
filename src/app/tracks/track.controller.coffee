'use strict'

angular.module('tracks').controller 'trackCtrl', ($stateParams, eeDefiner, eeTrack, eeTracks) ->

  track = this

  track.ee = eeDefiner.exports
  track.data = eeTrack.data

  eeTracks.fns.runSection()

  eeTrack.fns.get $stateParams.id
  .then (tr) -> track.data.track = tr

  return
