'use strict'

angular.module('admin.auth').config ($stateProvider) ->

  $stateProvider
    .state 'logout',
      url: '/logout'
      views:
        top:
          controller: 'logoutCtrl as logout'
          templateUrl: 'app/auth.logout/auth.logout.html'
      data:
        pageTitle: 'Logged out'
        padTop: '80px'

  return
