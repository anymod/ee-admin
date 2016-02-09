'use strict'

angular.module('analytics').config ($stateProvider) ->

  $stateProvider

    .state 'analytics',
      url: '/analytics'
      views:
        header:
          # controller: 'analyticsCtrl as analytics'
          templateUrl: 'app/analytics/analytics.header.html'
        top:
          controller: 'analyticsCtrl as analytics'
          templateUrl: 'app/analytics/analytics.html'
      data:
        pageTitle: 'Analytics'
        padTop:    '50px'

  return
