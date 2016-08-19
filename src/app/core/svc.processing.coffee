'use strict'

angular.module('app.core').factory 'eeProcessing', ($q, $interval, eeBack) ->

  ## SETUP
  _polling = undefined

  ## PRIVATE EXPORT DEFAULTS
  _data =
    status:
      err: null
      running: false
      dropbox: {}
    sections: ['dropbox', 'pricing', 'cloudinary', 'tags', 'elasticsearch']

  ## PRIVATE FUNCTIONS
  _setRunning = (section, value) ->
    value ||= false
    _data.status ||= {}
    _data.status[section] ||= {}
    if value is true then _data.status.err = null
    _data.status.running = value
    _data.status[section].running = value

  _processDropbox = () ->
    _setRunning 'dropbox', true
    _startPolling()
    eeBack.fns.processingDropboxPOST()
    .then (status) ->
      if status?.dropbox
        _data.status.dropbox[attr] = status.dropbox[attr] for attr in Object.keys(status.dropbox)
    .catch (err) ->
      _data.status.err = err
      _setRunning 'dropbox', false

  _indexElasticsearch = () ->
    _setRunning 'elasticsearch', true
    _startPolling()
    eeBack.fns.processingElasticsearchPOST()
    .then (status) ->
      if status?.elasticsearch then _data.status.elasticsearch[attr] = status.elasticsearch[attr] for attr in Object.keys(status.elasticsearch)
    .catch (err) ->
      _data.status.err = err
      _setRunning 'elasticsearch', false

  _runPricingAlgorithm = () ->
    _setRunning 'pricing', true
    _startPolling()
    eeBack.fns.processingPricingPOST()
    .then (status) ->
      if status?.pricing
        _data.status.pricing[attr] = status.pricing[attr] for attr in Object.keys(status.pricing)
    .catch (err) ->
      _data.status.err = err
      _setRunning 'pricing', false

  _runCloudinary = () ->
    _setRunning 'cloudinary', true
    _startPolling()
    eeBack.fns.processingCloudinaryPOST()
    .then (status) ->
      if status?.cloudinary
        _data.status.cloudinary[attr] = status.cloudinary[attr] for attr in Object.keys(status.cloudinary)
    .catch (err) ->
      _data.status.err = err
      _setRunning 'cloudinary', false

  _runTags = () ->
    _setRunning 'tags', true
    _startPolling()
    eeBack.fns.processingTagsPOST()
    .then (status) ->
      if status?.tags
        _data.status.tags[attr] = status.tags[attr] for attr in Object.keys(status.tags)
    .catch (err) ->
      _data.status.err = err
      _setRunning 'tags', false

  _getStatus = () ->
    eeBack.fns.processingStatusGET()
    .then (status) ->
      if typeof status is 'string' then throw 'problem getting process status'
      for section in _data.sections
        if status?[section] then _data.status[section][attr] = status[section][attr] for attr in Object.keys(status[section])
    .catch (err) ->
      _data.status.err = err

  _startPolling = () ->
    if _polling then _stopPolling()
    _polling = $interval(() ->
      _getStatus()
      .then () ->
        if _data.status.err or !_data.status.running? then _stopPolling()
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
    runCloudinary: _runCloudinary
    runTags: _runTags
