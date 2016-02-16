'use strict'

angular.module('collections').config ($stateProvider) ->

  $stateProvider
    .state 'collections',
      url: '/collections'
      views:
        header:
          # controller: 'collectionsCtrl as collections'
          templateUrl: 'app/collections/collections.header.html'
        top:
          controller: 'collectionsCtrl as collections'
          templateUrl: 'app/collections/collections.html'
      data:
        pageTitle:        'collections'
        padTop:           '60px'

  return
