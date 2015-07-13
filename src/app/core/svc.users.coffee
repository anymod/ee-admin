'use strict'

angular.module('app.core').factory 'eeUsers', ($q, eeBack, eeAuth) ->

  ## SETUP
  _inputDefaults =
    perPage:        48
    page:           null
    count:          null

  ## PRIVATE EXPORT DEFAULTS
  _data =
    users:          []
    inputs:         _inputDefaults
    showDetailsFor: null
    searching:      false

  ## PRIVATE FUNCTIONS
  _formQuery = () ->
    query = {}
    if _data.inputs.page  then query.page   = _data.inputs.page
    if _data.inputs.order then query.order  = _data.inputs.order
    query

  _runQuery = () ->
    deferred = $q.defer()
    # if searching then avoid simultaneous calls to API
    if !!_data.searching then return _data.searching
    _data.searching = deferred.promise
    eeBack.usersGET eeAuth.fns.getToken(), _formQuery()
    .then (res) ->
      _data.inputs.count = res.count
      _data.users        = res.rows
      deferred.resolve _data.users
    .catch (err) ->
      console.error err
      deferred.reject err
    .finally () ->
      _data.searching = false
    deferred.promise

  # _updateLead = (newLead) ->
  #   assignKey = (key, newLead, oldLead) -> if !!key and !!newLead[key] then oldLead[key] = newLead[key]
  #   updateIfMatch = (n) ->
  #     oldLead = _data.leads[n]
  #     if !!oldLead and oldLead.id is newLead.id
  #       console.log 'updating', n, oldLead
  #       assignKey(key, newLead, oldLead) for key in Object.keys(oldLead)
  #       return true
  #   updateIfMatch n for n in [0.._data.leads.length]
  #   return false

  # _alterLead = (lead) ->
  #   lead.updating = true
  #   eeBack.leadPUT lead, eeAuth.fns.getToken()
  #   .then (res) ->
  #     _updateLead res
  #     lead.error = null
  #   .catch (err) -> lead.error = err
  #   .finally () -> lead.updating = false

  ## EXPORTS
  data: _data
  fns:
    update: () -> _runQuery()
    search: () ->
      _data.inputs.page = 1
      _runQuery()
    incrementPage: () ->
      _data.inputs.page = if _data.inputs.page < 1 then 2 else _data.inputs.page + 1
      _runQuery()
    decrementPage: () ->
      _data.inputs.page = if _data.inputs.page < 2 then 1 else _data.inputs.page - 1
      _runQuery()
    setOrder: (order) ->
      _data.inputs.page = 1
      _data.inputs.order = if _data.inputs.order is order then null else order
      _runQuery()
