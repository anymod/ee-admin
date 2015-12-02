'use strict'
module = angular.module 'ee-storefront-logo', []

module.directive "eeStorefrontLogo", () ->
  templateUrl: 'components/ee-storefront-logo.html'
  restrict: 'EA'
  scope:
    meta:     '='
    sref:     '@'
    blocked:  '@'
  link: (scope, ele, attrs) ->
    if !scope.sref
      scope.sref = '-'
      scope.blocked = true
    return
