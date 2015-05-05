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

  _updateLead = (newLead) ->
    assignKey = (key, newLead, oldLead) -> if !!key and !!newLead[key] then oldLead[key] = newLead[key]
    updateIfMatch = (n) ->
      oldLead = _data.leads[n]
      if !!oldLead and oldLead.id is newLead.id
        console.log 'updating', n, oldLead
        assignKey(key, newLead, oldLead) for key in Object.keys(oldLead)
        return true
    updateIfMatch n for n in [0.._data.leads.length]
    return false

  _alterLead = (lead) ->
    lead.updating = true
    eeBack.leadPUT lead, eeAuth.fns.getToken()
    .then (res) ->
      _updateLead res
      lead.error = null
    .catch (err) -> lead.error = err
    .finally () -> lead.updating = false

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
    alterLead: _alterLead
    toggleIgnoreLead: (lead) ->
      lead.ignored = !lead.ignored
      _alterLead lead
    toggleSentLead: (lead) ->
      if !lead.sent_at then lead.sent_at = new Date() else lead.sent_at = null
      _alterLead lead
