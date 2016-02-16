'use strict'

angular.module('app.core').factory 'eeCollections', ($rootScope, $q, eeBack, eeAuth, eeModal) ->

  ## SETUP
  _inputDefaults =
    perPage:      48
    page:         null
    search:       null
    searchLabel:  null
    order:        { order: 'updated_at DESC', title: 'Most relevant' }
    featured:     false

  ## PRIVATE EXPORT DEFAULTS
  _data =
    count:    null
    collections: []
    inputs:   angular.copy _inputDefaults
    reading:  false

  ## PRIVATE FUNCTIONS
  _formQuery = () ->
    query = {}
    query.size = _data.inputs.perPage
    if _data.inputs.featured  then query.feat   = 'true'
    if _data.inputs.page      then query.page   = _data.inputs.page
    if _data.inputs.search    then query.search = _data.inputs.search
    if _data.inputs.order.use then query.order  = _data.inputs.order.order
    query

  _runQuery = () ->
    if _data.reading then return
    _data.reading = true
    eeBack.fns.collectionsGET eeAuth.fns.getToken(), _formQuery()
    .then (res) ->
      { rows, count, took } = res
      _data.collections   = rows
      _data.count         = count
      _data.took = took
      _data.inputs.searchLabel = _data.inputs.search
    .catch (err) -> _data.count = null
    .finally () -> _data.reading = false

  ## MESSAGING
  # none

  ## EXPORTS
  data: _data
  fns:
    runQuery: _runQuery
