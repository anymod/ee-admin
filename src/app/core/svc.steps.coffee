'use strict'

angular.module('app.core').factory 'eeSteps', (eeBack, eeAuth) ->

  ## SETUP
  _inputDefaults =
    perPage: 256
    page:    null

  ## PRIVATE EXPORT DEFAULTS
  _data =
    count:    null
    steps:    []
    hrefs:    []
    inputs:   angular.copy _inputDefaults
    reading:  false

  ## PRIVATE FUNCTIONS
  _formQuery = () ->
    query = {}
    query.size = _data.inputs.perPage
    if _data.inputs.hrefOnly  then query.hrefOnly = _data.inputs.hrefOnly
    if _data.inputs.order     then query.order    = _data.inputs.order
    query

  _runQuery = () ->
    if _data.reading then return
    _data.reading = true
    eeBack.fns.stepsGET eeAuth.fns.getToken(), _formQuery()
    .then (res) ->
      { rows, count, took } = res
      _data.steps = rows
      _data.count = count
      _data.took  = took
    .catch (err) -> _data.count = null
    .finally () -> _data.reading = false

  _parseHrefs = () ->
    _data.hrefs = []
    for step in _data.steps
      hrefs = step.html.match(/href="[^"]+"/ig)
      for href, i in hrefs
        _data.hrefs.push {
          i: i
          track_id: step.track_id,
          step_id: step.id,
          title: step.title,
          url: href.split(/"/g)[1],
          url_title: href.split(/"/g)[1].replace('http://', '').replace('https://', '').replace('www.', '')
        }

  ## EXPORTS
  data: _data
  fns:
    runQuery: () ->
      _data.inputs.order = 'id asc'
      _data.inputs.hrefOnly = true
      _runQuery()
      .then () -> _parseHrefs()
