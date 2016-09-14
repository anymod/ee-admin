'use strict'

angular.module('products').config ($stateProvider) ->

  views =
    header:
      controller: 'productsCtrl as products'
      templateUrl: 'app/products/products.header.html'
    top:
      controller: 'productsCtrl as products'
      templateUrl: 'app/products/products.html'

  data =
    pageTitle: 'Products'
    padTop:    '111px'

  $stateProvider
    .state 'products',
      url:   '/products'
      views: views
      data:  data
    .state 'products.pricing',
      url:    '/pricing'
      views:  views
    .state 'products.tags',
      url:    '/tags'
      views:  views
    .state 'products.text',
      url:    '/text'
      views:  views
    .state 'products.properties',
      url:    '/properties'
      views:  views
    .state 'products.processing',
      url:    '/processing'
      views:  views

  return
