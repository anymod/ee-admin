'use strict'

angular.module('taxonomies').config ($stateProvider) ->

  views =
    header:
      controller: 'taxonomiesCtrl as taxonomies'
      templateUrl: 'app/taxonomies/taxonomies.header.html'
    top:
      controller: 'taxonomiesCtrl as taxonomies'
      templateUrl: 'app/taxonomies/taxonomies.html'

  data =
    pageTitle:        'Taxonomy'
    padTop:           '50px'

  $stateProvider
    .state 'taxonomy',
      url: '/taxonomy'
      views: views
      data: data

  return
