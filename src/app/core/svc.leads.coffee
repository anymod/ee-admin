'use strict'

angular.module('app.core').factory 'eeLeads', ($q, eeBack, eeAuth) ->

  ## SETUP
  _inputDefaults =
    perPage:        100
    page:           null
    search:         null
    count:          null

  ## PRIVATE EXPORT DEFAULTS
  _data =
    leads:          []
    inputs:         _inputDefaults
    showDetailsFor: null
    searching:      false

  ## PRIVATE FUNCTIONS
  _formQuery = () ->
    query = {}
    if _data.inputs.page      then query.page       = _data.inputs.page
    if _data.inputs.search    then query.search     = _data.inputs.search
    query

  _runQuery = () ->
    deferred = $q.defer()
    # if searching then avoid simultaneous calls to API
    if !!_data.searching then return _data.searching
    _data.searching = deferred.promise
    eeBack.leadsGET eeAuth.fns.getToken(), _formQuery()
    .then (res) ->
      console.log res
      _data.inputs.count = res.count
      _data.leads        = res.rows
      deferred.resolve _data.leads
    .catch (err) ->
      console.error err
      deferred.reject err
    .finally () ->
      _data.searching = false
    deferred.promise

  ## EXPORTS
  data: _data
  fns:
    search: () ->
      _data.inputs.page = 1
      _runQuery()
    update: () ->
      _runQuery()
    incrementPage: () ->
      _data.inputs.page = if _data.inputs.page < 1 then 2 else _data.inputs.page + 1
      _runQuery()
    decrementPage: () ->
      _data.inputs.page = if _data.inputs.page < 2 then 1 else _data.inputs.page - 1
      _runQuery()
    showDetailsFor: (id) ->
      _data.showDetailsFor = if _data.showDetailsFor is id then null else id
