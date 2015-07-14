'use strict'

angular.module('demo').config ($stateProvider) ->

  views =
    header:
      controller: 'demoCtrl as demo'
      templateUrl: 'app/demo/demo.header.html'
    top:
      controller: 'demoCtrl as demo'
      templateUrl: 'app/demo/demo.html'

  data =
    pageTitle:        'Demo'
    padTop:           '50px'

  $stateProvider
    .state 'demo',
      url:      '/demo'
      views:    views
      data:     data

  return
