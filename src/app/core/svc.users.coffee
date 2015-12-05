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
    eeBack.fns.usersGET eeAuth.fns.getToken(), _formQuery()
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

  _toggleOrder = () ->
    return if !_data.inputs.order
    _data.inputs.order = if _data.inputs.order.indexOf('_asc') > -1 then _data.inputs.order.replace(/_asc/g, '_desc') else _data.inputs.order.replace(/_desc/g, '_asc')

  _setOrder = (metric) ->
    _data.inputs.page = 1
    order = if metric.indexOf('_at') > -1 or metric is 'id' then metric + '_desc' else metric + '_asc'

    console.log metric, _data.inputs.order, order

    if order is _data.inputs.order then _toggleOrder() else _data.inputs.order = order

    console.log metric, _data.inputs.order, order


    #   if !_data.inputs.order then _data.inputs.order = metric + '_desc' else _toggleOrder()
    # else
    #   if !_data.inputs.order then _data.inputs.order = metric + '_asc' else _toggleOrder()
      # _data.inputs.order = if _data.inputs.order.split('_')[0] is metric.split('_')[0] then metric + '_desc' else metric + '_asc'
    _runQuery()


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
  #   eeBack.fns.leadPUT lead, eeAuth.fns.getToken()
  #   .then (res) ->
  #     _updateLead res
  #     lead.error = null
  #   .catch (err) -> lead.error = err
  #   .finally () -> lead.updating = false

  ## EXPORTS
  data: _data
  fns:
    setOrder: _setOrder
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
