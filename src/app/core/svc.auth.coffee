'use strict'

angular.module('app.core').factory 'eeAuth', ($rootScope, $cookies, $q, eeBack) ->

  ## SETUP
  _status = {}

  ## PRIVATE EXPORT DEFAULTS
  _user = {}

  ## PRIVATE FUNCTIONS
  _userLastSet  = Date.now()
  _userIsEmpty  = () -> Object.keys(_user).length is 0

  _setUser = (u) ->
    assignKey = (k) -> _user[k] = u[k]
    assignKey key for key in Object.keys u
    _user

  _setadminToken = (token) -> $cookies.put 'adminToken', token
  _clearadminToken = () -> $cookies.remove 'adminToken'

  _reset = () ->
    _clearadminToken()
    _setUser {}
    $rootScope.$emit 'definer:logout'

  _defineUserFromToken = () ->
    deferred = $q.defer()

    if !!_status.fetching then return _status.fetching
    if !$cookies.get('adminToken') then deferred.reject('Missing login credentials'); return deferred.promise
    _status.fetching = deferred.promise

    eeBack.fns.tokenPOST $cookies.get('adminToken')
    .then (data) ->
      if !data.admin then return _reset()
      _setUser data
      if !!data.email then deferred.resolve(data) else deferred.reject(data)
    .catch (err) ->
      _reset()
      deferred.reject err
    .finally () -> _status.fetching = false
    deferred.promise

  ## EXPORTS
  exports:
    user: _user
  fns:
    logout:               () -> _reset()
    hasToken:             () -> !!$cookies.get('adminToken')
    getToken:             () -> $cookies.get('adminToken')
    defineUserFromToken:  () -> _defineUserFromToken()

    setAdminFromCredentials: (email, password) ->
      deferred = $q.defer()
      if !email or !password
        _reset()
        deferred.reject 'Missing login credentials'
      else
        eeBack.fns.authPOST(email, password)
        .then (data) ->
          if !data.user?.admin
            deferred.reject 'Not an admin'
          else if !!data.user and !!data.token
            _setadminToken data.token
            _setUser data.user
            $rootScope.$emit 'definer:login'
            deferred.resolve data.user
          else
            _reset()
            deferred.reject data
        .catch (err) ->
          _reset()
          deferred.reject err
        .finally () -> _status.landing = false
      deferred.promise
