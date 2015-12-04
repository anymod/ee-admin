'use strict'

angular.module('users').config ($stateProvider) ->

  views =
    header:
      controller: 'usersCtrl as users'
      templateUrl: 'app/users/users.header.html'
    top:
      controller: 'usersCtrl as users'
      templateUrl: 'app/users/users.html'

  data =
    pageTitle:        'Users'
    padTop:           '100px'

  $stateProvider
    .state 'users',
      url:      '/users'
      views:    views
      data:     data
    .state 'users.onboard',
      url:    '/onboard'
      views:  views
    .state 'users.info',
      url:    '/info'
      views:  views
    .state 'users.activity',
      url:    '/activity'
      views:  views

  return
