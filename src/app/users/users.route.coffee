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
      url:   '/users'
      views: views
      data:  data
    .state 'users.info',
      url:    '/info'
      views:  views
    .state 'users.social',
      url:    '/social'
      views:  views
    .state 'users.branding',
      url:    '/branding'
      views:  views
    .state 'users.analytics',
      url:    '/analytics'
      views:  views

    .state 'user',
      url: '/users/:id'
      views:
        header:
          templateUrl: 'app/users/users.header.html'
        top:
          controller: 'userCtrl as user'
          templateUrl: 'app/users/user.html'
        middle:
          controller: 'userDashboardCtrl as user'
          templateUrl: 'app/users/user.dashboard.html'
      data:
        pageTitle: 'User details'
        padTop:    '100px'
    .state 'date',
      url: '/users/:id/date/:year/:month/:day'
      views:
        header:
          templateUrl: 'app/users/users.header.html'
        top:
          controller: 'userCtrl as user'
          templateUrl: 'app/users/user.html'
        middle:
          controller: 'userDashboardCtrl as user'
          templateUrl: 'app/users/user.dashboard.html'
      data:
        pageTitle: 'User details'
        padTop:    '100px'

  return
