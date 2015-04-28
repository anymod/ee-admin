'use strict'

angular.module('admin').config ($stateProvider) ->

  views =
    header:
      controller: 'adminCtrl as admin'
      templateUrl: 'app/admin/admin.header.html'
    top:
      controller: 'adminCtrl as admin'
      templateUrl: 'app/admin/admin.html'

  data =
    pageTitle:        'Admin | eeosk'
    padTop:           '88px'

  $stateProvider
    .state 'home',
      url:      '/'
      views:    views
      data:     data

  return
