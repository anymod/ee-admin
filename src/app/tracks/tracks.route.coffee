'use strict'

angular.module('tracks').config ($stateProvider) ->

  $stateProvider

    .state 'tracks',
      url: '/tracks'
      views:
        header:
          # controller: 'tracksCtrl as tracks'
          templateUrl: 'app/tracks/tracks.header.html'
        top:
          controller: 'tracksCtrl as tracks'
          templateUrl: 'app/tracks/tracks.html'
      data:
        pageTitle: 'Tracks'
        padTop:    '111px'

    .state 'track',
      url: '/tracks/:id/:title'
      views:
        header:
          # controller: 'tracksCtrl as tracks'
          templateUrl: 'app/tracks/tracks.header.html'
        top:
          controller: 'trackCtrl as track'
          templateUrl: 'app/tracks/track.html'
      data:
        pageTitle: 'Track'
        padTop:    '111px'

    .state 'links',
      url: '/links'
      views:
        header:
          # controller: 'tracksCtrl as tracks'
          templateUrl: 'app/tracks/tracks.header.html'
        top:
          controller: 'tracksCtrl as tracks'
          templateUrl: 'app/tracks/tracks.links.html'
      data:
        pageTitle: 'Tracks'
        padTop:    '111px'

  return
