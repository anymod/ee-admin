'use strict'

angular.module('app.core').factory 'eeTracks', ($rootScope, $q, eeBack, eeAuth) ->

  ## SETUP
  _inputDefaults =
    perPage:      48
    page:         null
    search:       null
    searchLabel:  null
    range:
      min:        null
      max:        null
    category:     null
    supplier_id:  null
    order:        { order: null, title: 'Most relevant' }
    featured:     false
    categoryArray: [
      { id: 1, title: 'Artwork' },
      { id: 2, title: 'Bed & Bath' },
      { id: 3, title: 'Furniture' },
      { id: 4, title: 'Home Accents' },
      { id: 5, title: 'Kitchen' },
      { id: 6, title: 'Outdoor' }
    ]
    rangeArray: [
      { min: 0,     max: 2500   },
      { min: 2500,  max: 5000   },
      { min: 5000,  max: 10000  },
      { min: 10000, max: 20000  },
      { min: 20000, max: null   }
    ]
    orderArray: [
      { order: null,          title: 'Most relevant' },
      { order: 'price ASC',   title: 'Price, low to high',  use: true },
      { order: 'price DESC',  title: 'Price, high to low',  use: true },
      { order: 'title ASC',   title: 'A to Z',              use: true },
      { order: 'title DESC',  title: 'Z to A',              use: true }
    ]

  ## PRIVATE EXPORT DEFAULTS
  _data =
    count:    null
    tracks:   []
    inputs:   angular.copy _inputDefaults
    reading:  false
    lastCollectionAddedTo: null

  ## PRIVATE FUNCTIONS
  _clearSection = () ->
    _data.tracks = []
    _data.count = 0

  _formQuery = () ->
    query = {}
    query.size = _data.inputs.perPage
    if _data.inputs.featured     then query.feat         = 'true'
    if _data.inputs.page         then query.page         = _data.inputs.page
    if _data.inputs.search       then query.search       = _data.inputs.search
    if _data.inputs.range.min    then query.min_price    = _data.inputs.range.min
    if _data.inputs.range.max    then query.max_price    = _data.inputs.range.max
    if _data.inputs.order.use    then query.order        = _data.inputs.order.order
    if _data.inputs.supplier_id  then query.supplier_id  = _data.inputs.supplier_id
    if _data.inputs.category     then query.category_ids = [_data.inputs.category.id]
    query

  _runQuery = (queryPromise) ->
    if _data.reading then return
    _data.reading = true
    queryPromise
    .then (res) ->
      console.log 'res', res
      { rows, count, took } = res
      _data.tracks  = rows
      _data.count   = count
      _data.took    = took
      _data.inputs.searchLabel = _data.inputs.search
    .catch (err) -> _data.count = null
    .finally () -> _data.reading = false

  _runSection = () ->
    if _data.reading then return
    promise = eeBack.fns.tracksGET(eeAuth.fns.getToken(), _formQuery())
    _runQuery promise

  # _searchWithTerm = (term) ->
  #   _data.search.inputs.order = _data.search.inputs.orderArray[0]
  #   _data.search.inputs.search = term
  #   _data.search.inputs.page = 1
  #   _runSection()

  _addTrackModal = (track, type) ->
    track.err = null
    eeModal.fns.openTrackModal track, type
    return

  ## MESSAGING
  # $rootScope.$on 'reset:tracks', () -> _data.search.tracks = []
  #
  # $rootScope.$on 'track:added', (e, track, collection) ->
    # _data.search.lastCollectionAddedTo = collection.id
    # (if track.id is prod.id then prod.trackId = track.trackId) for prod in _data.search.tracks
    # eeModal.fns.close('addTrack')

  _copyTrack = (fromTrack, toTrack) ->
    toTrack[prop] = fromTrack[prop] for prop in ['title', 'icon', 'lanes', 'type', 'last_lane_name', 'show']

  $rootScope.$on 'track:updated', (e, track) ->
    (if track.id is tr.id then _copyTrack(track, tr)) for tr in _data.tracks

  ## EXPORTS
  data: _data
  fns:
    runSection: _runSection
    # search: _searchWithTerm
    featured: () ->
      _clearSection()
      _data.inputs.page      = 1
      _data.inputs.featured  = true
      _runSection()
    # clearSearch: () -> _searchWithTerm ''
    setCategory: (category) ->
      _data.inputs.page      = 1
      _data.inputs.category  = category
      _runSection()
    setOrder: (order) ->
      _data.inputs.search  = if !order?.order then _data.inputs.searchLabel else null
      _data.inputs.page    = 1
      _data.inputs.order   = order
      _runSection()
    setRange: (range) ->
      range = range || {}
      _data.inputs.page = 1
      if _data.inputs.range.min is range.min and _data.inputs.range.max is range.max
        _data.inputs.range.min = null
        _data.inputs.range.max = null
      else
        _data.inputs.range.min = range.min
        _data.inputs.range.max = range.max
      _runSection()
    toggleFeatured: () ->
      _data.inputs.page      = 1
      _data.inputs.featured  = !_data.inputs.featured
      _runSection()
    addTrackModal: _addTrackModal
