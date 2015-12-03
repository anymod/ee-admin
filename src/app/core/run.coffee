'use strict'

angular.module('app.core').run ($rootScope, $location, $anchorScroll, $state, eeAuth, templatesPerPage) ->

  $rootScope.templatesPerPage = templatesPerPage
  $rootScope.$state   = $state
  $rootScope.isAdmin  = true

  Keen.ready () ->
    $rootScope.keenio = new Keen
      projectId: "565c9b27c2266c0bb36521db",
      readKey: "2e6b0efec92fef795b3f2f42cb77f8f9d9f07e6db31afdd27cf1b296657edeb9c7b3e4dccbe0019587d5b7e6b2221fb669114f7afa7813f081c3414df1a06b33bbd2fd26d71df0fa88f194dce9281c15b825dcd803fd61c824b8c45701cbe61c46e00cc4df1ca908f322b8f5ca60e856"

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
    if loggedIn and isOpen(toState.name) and toState.name isnt 'logout' then return stopAndRedirectTo('activity')

    return

  return

  return
