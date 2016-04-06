'use strict'

angular.module('app.core').factory 'eeProcessing', ($q, $interval, eeBack) ->

  ## SETUP
  _polling = undefined

  ## PRIVATE EXPORT DEFAULTS
  _data =
    status:
      err: null
      update: {}
      create: {}

  ## PRIVATE FUNCTIONS
  _update = () ->
    _data.status ||= {}
    _data.status.err = null
    _data.status.update =
      running: true
    _startPolling()
    eeBack.fns.processingUpdatePOST()
    .then (status) ->
      if status?.update then _data.status.update[attr] = status.update[attr] for attr in Object.keys(status.update)
    .catch (err) ->
      _data.status.err = err
      _data.status.update.running = false

  _indexElasticsearch = () ->
    _data.status ||= {}
    _data.status.err = null
    _data.status.elasticsearch =
      running: true
    _startPolling()
    eeBack.fns.processingElasticsearchPOST()
    .then (status) ->
      if status?.elasticsearch then _data.status.elasticsearch[attr] = status.elasticsearch[attr] for attr in Object.keys(status.elasticsearch)
    .catch (err) ->
      _data.status.err = err
      _data.status.elasticsearch.running = false

  _getStatus = () ->
    eeBack.fns.processingStatusGET()
    .then (status) ->
      if typeof status is 'string' then throw 'problem getting process status'
      for section in ['create', 'update', 'elasticsearch']
        if status?[section] then _data.status[section][attr] = status[section][attr] for attr in Object.keys(status[section])
    .catch (err) ->
      _data.status.err = err

  _startPolling = () ->
    if _polling then _stopPolling()
    _polling = $interval(() ->
      _getStatus()
      .then () ->
        if _data.status.err then _stopPolling()
        if !_data.status.update.running and !_data.status.create.running and !_data.status.elasticsearch.running then _stopPolling()
    , 2000)

  _stopPolling = () ->
    $interval.cancel _polling
    _polling = undefined

  ## EXPORTS
  data: _data
  fns:
    update: _update
    indexElasticsearch:  _indexElasticsearch
