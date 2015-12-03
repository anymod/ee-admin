'use strict'

angular.module('activity').config ($stateProvider) ->

  $stateProvider

    .state 'activity',
      url: '/activity'
      views:
        header:
          # controller: 'activityCtrl as activity'
          templateUrl: 'app/activity/activity.header.html'
        top:
          controller: 'activityCtrl as activity'
          templateUrl: 'app/activity/activity.html'
      data:
        pageTitle: 'Activity'
        padTop:    '50px'

  return
