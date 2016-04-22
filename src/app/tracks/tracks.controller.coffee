'use strict'

angular.module('tracks').controller 'tracksCtrl', ($state, eeDefiner, eeTracks, eeSteps) ->

  tracks = this

  tracks.ee = eeDefiner.exports

  eeTracks.fns.runSection()

  if $state.current.name is 'links'
    tracks.data = eeSteps.data
    eeSteps.fns.runQuery()

  return
