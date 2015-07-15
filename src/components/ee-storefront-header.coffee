'use strict'

module = angular.module 'ee-storefront-header', []

module.directive "eeStorefrontHeader", ($rootScope, $state) ->
  templateUrl: 'components/ee-storefront-header.html'
  restrict: 'E'
  scope:
    meta:           '='
    blocked:        '='
    loading:        '='
    collections:    '='
    quantityArray:  '='
  link: (scope, ele, attrs) ->
    scope.isStore     = $rootScope.isStore
    scope.isBuilder   = $rootScope.isBuilder
    scope.state       = $state.current.name
    # scope.cart        = eeCart.cart
    return
