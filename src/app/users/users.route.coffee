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
    padTop:           '50px'

  $stateProvider
    .state 'users',
      url:      '/users'
      views:    views
      data:     data

  return
