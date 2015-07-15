'use strict'

angular.module('app.core').run ($rootScope, $location, $anchorScroll, $state, eeAuth, productsPerPage) ->

  $rootScope.productsPerPage = productsPerPage
  $rootScope.$state   = $state
  $rootScope.isAdmin  = true

  openStates = [
    'landing'
    'login'
    'logout'
  ]

  isOpen    = (state) -> openStates.indexOf(state) > -1
  needsAuth = (state) -> !isOpen state

  $rootScope.$on '$stateChangeSuccess', () ->
    search = $location.search()
    $location.hash 'body-top'
    $anchorScroll()
    $location.url $location.path()
    $location.search search

  $rootScope.$on '$stateChangeStart', (event, toState, toParams, fromState, fromParams) ->
    loggedIn  = eeAuth.fns.hasToken()
    loggedOut = !loggedIn

    stopAndRedirectTo = (state) ->
      event.preventDefault()
      $state.go state
      # If redirect loop: $state.go causes this with child state, so use $location.path for storefront instead. See https://github.com/angular-ui/ui-router/issues/1169
      return

    # redirect to login if logged out and restricted
    if loggedOut and needsAuth(toState.name) then return stopAndRedirectTo('login')
    # redirect to storefront if logged in and unrestricted
    if loggedIn and isOpen(toState.name) and toState.name isnt 'logout' then return stopAndRedirectTo('users')

    return

  return

  return
