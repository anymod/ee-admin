'use strict'

module = angular.module 'ee-loading', []

angular.module('ee-loading').directive "eeLoading", () ->
  templateUrl: 'components/ee-loading.html'
  restrict: 'E'
  scope:
    loading: '='
