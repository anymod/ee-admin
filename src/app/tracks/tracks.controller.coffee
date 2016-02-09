'use strict'

angular.module('tracks').controller 'tracksCtrl', (eeDefiner, eeTracks) ->

  tracks = this

  tracks.ee = eeDefiner.exports

  eeTracks.fns.runSection()

  return
