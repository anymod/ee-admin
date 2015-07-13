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
    pageTitle:        'Products'
    padTop:           '100px'

  $stateProvider
    .state 'products',
      url:      '/products'
      views:    views
      data:     data

  return
