'use strict'

angular.module('customers').config ($stateProvider) ->

  $stateProvider

    .state 'customers',
      url: '/customers'
      views:
        header:
          # controller: 'customersCtrl as customers'
          templateUrl: 'app/customers/customers.header.html'
        top:
          controller: 'customersCtrl as customers'
          templateUrl: 'app/customers/customers.html'
      data:
        pageTitle: 'Customers'
        padTop:    '50px'

  return
