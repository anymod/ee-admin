'use strict'

angular.module('app.core').factory 'eeDefiner', ($rootScope, eeAuth, eeProducts) ->

  ## SETUP
  _loggedIn  = eeAuth.fns.hasToken()
  _loggedOut = !_loggedIn

  _exports =
    Products:   eeProducts.data
    logged_in:  _loggedIn
    loading:    {}
    blocked:    {}
    unsaved:    false

  ## PRIVATE FUNCTIONS
  _fillExportData = (user, data) ->
    _exports.logged_in = eeAuth.fns.hasToken()

  _defineLoggedIn = () ->
    console.info '_defineLoggedIn'
    _exports.logged_in  = true
    _exports.loading    = true
    _exports.blocked    = false
    eeAuth.fns.defineUserFromToken()
    .then     () -> _fillExportData eeAuth.exports.user, {}
    .catch (err) -> console.error err
    .finally  () -> _exports.loading = false

  _defineLanding = () ->
    console.info '_defineLanding'
    _exports.logged_in  = false
    _exports.loading    = false
    _exports.blocked    = true
    _fillExportData {}, {}

  ## DEFINITION LOGIC
  if _loggedIn  then _defineLoggedIn()
  if _loggedOut then _defineLanding()

  $rootScope.$on 'definer:login',   () -> _defineLoggedIn()
  $rootScope.$on 'definer:logout',  () -> _defineLanding()

  ## EXPORTS
  exports: _exports
