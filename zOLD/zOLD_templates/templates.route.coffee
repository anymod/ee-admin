'use strict'

angular.module('templates').config ($stateProvider) ->

  views =
    header:
      controller: 'templatesCtrl as templates'
      templateUrl: 'app/templates/templates.header.html'
    top:
      controller: 'templatesCtrl as templates'
      templateUrl: 'app/templates/templates.html'

  data =
    pageTitle:        'Products'
    padTop:           '100px'

  $stateProvider
    .state 'templates',
      url:      '/templates'
      views:    views
      data:     data

  return
