'use strict'

angular.module('app.core').factory 'eeProcessing', ($q, $interval, eeBack) ->

  ## SETUP
  _polling = undefined

  ## PRIVATE EXPORT DEFAULTS
  _data =
    status:
      err: null
      dropbox: {}

  ## PRIVATE FUNCTIONS
  _processDropbox = () ->
    _data.status ||= {}
    _data.status.err = null
    _data.status.dropbox =
      running: true
    _startPolling()
    eeBack.fns.processingDropboxPOST()
    .then (status) ->
      if status?.dropbox
        _data.status.dropbox[attr] = status.dropbox[attr] for attr in Object.keys(status.dropbox)
    .catch (err) ->
      _data.status.err = err
      _data.status.dropbox.running = false

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

  _runPricingAlgorithm = () ->
    _data.status ||= {}
    _data.status.err = null
    _data.status.pricing =
      running: true
    _startPolling()
    eeBack.fns.processingPricingPOST()
    .then (status) ->
      if status?.pricing
        _data.status.pricing[attr] = status.pricing[attr] for attr in Object.keys(status.pricing)
    .catch (err) ->
      _data.status.err = err
      _data.status.pricing.running = false

  _getStatus = () ->
    eeBack.fns.processingStatusGET()
    .then (status) ->
      if typeof status is 'string' then throw 'problem getting process status'
      for section in ['dropbox', 'elasticsearch', 'pricing']
        if status?[section] then _data.status[section][attr] = status[section][attr] for attr in Object.keys(status[section])
    .catch (err) ->
      _data.status.err = err

  _startPolling = () ->
    if _polling then _stopPolling()
    _polling = $interval(() ->
      _getStatus()
      .then () ->
        if _data.status.err then _stopPolling()
        if !_data.status.dropbox?.running and !_data.status.elasticsearch?.running and !_data.status.pricing?.running then _stopPolling()
    , 2000)

  _stopPolling = () ->
    $interval.cancel _polling
    _polling = undefined

  ## EXPORTS
  data: _data
  fns:
    processDropbox: _processDropbox
    indexElasticsearch:  _indexElasticsearch
    runPricingAlgorithm:  _runPricingAlgorithm
