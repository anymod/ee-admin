'use strict'

angular.module('app.core').factory 'eeProducts', ($rootScope, $q, eeBack, eeAuth, eeModal) ->

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
    storefront:
      count:    null
      products: []
      inputs:   angular.copy _inputDefaults
      reading:  false
      lastCollectionAddedTo: null
    search:
      count:    null
      products: []
      inputs:   angular.copy _inputDefaults
      reading:  false
      lastCollectionAddedTo: null

  ## PRIVATE FUNCTIONS
  _clearSection = (section) ->
    _data.products = []
    _data[section].count    = 0

  _formQuery = (section) ->
    query = {}
    query.size = _data[section].inputs.perPage
    # if section is 'featured'            then query.feat         = 'true'
    if _data[section].inputs.featured   then query.feat         = 'true'
    if _data[section].inputs.page       then query.page         = _data[section].inputs.page
    if _data[section].inputs.search     then query.search       = _data[section].inputs.search
    if _data[section].inputs.range.min  then query.min_price    = _data[section].inputs.range.min
    if _data[section].inputs.range.max  then query.max_price    = _data[section].inputs.range.max
    if _data[section].inputs.order.use  then query.order        = _data[section].inputs.order.order
    if _data[section].inputs.category   then query.category_ids = [_data[section].inputs.category.id]
    query

  _runQuery = (section, queryPromise) ->
    if _data[section].reading then return
    _data[section].reading = true
    queryPromise
    .then (res) ->
      { rows, count, took } = res
      _data[section].products      = rows
      _data[section].count         = count
      _data[section].took = took
      _data[section].inputs.searchLabel = _data[section].inputs.search
    .catch (err) -> _data[section].count = null
    .finally () -> _data[section].reading = false

  _runSection = (section) ->
    if _data[section].reading then return
    switch section
      when 'storefront' then promise = eeBack.fns.productsGET(eeAuth.fns.getToken(), _formQuery('storefront'))
      when 'search'     then promise = eeBack.fns.productsGET(eeAuth.fns.getToken(), _formQuery('search'))
    _runQuery section, promise

  _searchWithTerm = (term) ->
    _data.search.inputs.order = _data.search.inputs.orderArray[0]
    _data.search.inputs.search = term
    _data.search.inputs.page = 1
    _runSection 'search'

  _addProductModal = (product, type) ->
    product.err = null
    eeModal.fns.openProductModal product, type
    return

  ## MESSAGING
  # $rootScope.$on 'reset:products', () -> _data.search.products = []
  #
  $rootScope.$on 'added:product', (e, product, collection) ->
    _data.search.lastCollectionAddedTo = collection.id
    # (if product.id is prod.id then prod.productId = product.productId) for prod in _data.search.products
    # eeModal.fns.close('addProduct')

  ## EXPORTS
  data: _data
  fns:
    runSection: _runSection
    search: _searchWithTerm
    featured: () ->
      section = 'storefront'
      _clearSection section
      _data[section].inputs.page      = 1
      _data[section].inputs.featured  = true
      _runSection section
    clearSearch: () -> _searchWithTerm ''
    setCategory: (category, section) ->
      _data[section].inputs.page      = 1
      _data[section].inputs.category  = category
      _runSection section
    setOrder: (order, section) ->
      _data[section].inputs.search  = if !order?.order then _data[section].inputs.searchLabel else null
      _data[section].inputs.page    = 1
      _data[section].inputs.order   = order
      _runSection section
    setRange: (range, section) ->
      range = range || {}
      _data[section].inputs.page = 1
      if _data[section].inputs.range.min is range.min and _data[section].inputs.range.max is range.max
        _data[section].inputs.range.min = null
        _data[section].inputs.range.max = null
      else
        _data[section].inputs.range.min = range.min
        _data[section].inputs.range.max = range.max
      _runSection section
    toggleFeatured: (section) ->
      _data[section].inputs.page      = 1
      _data[section].inputs.featured  = !_data[section].inputs.featured
      _runSection section
    addProductModal: _addProductModal
