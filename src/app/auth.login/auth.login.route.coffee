'use strict'

angular.module('admin.auth').config ($stateProvider) ->

  $stateProvider
    .state 'login',
      url: '/login'
      views:
        top:
          controller: 'loginCtrl as login'
          templateUrl: 'app/auth.login/auth.login.html'
      data:
        pageTitle: 'Login'
        padTop: '80px'

  return
