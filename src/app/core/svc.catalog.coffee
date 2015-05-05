'use strict'

angular.module('app.core').factory 'eeCatalog', ($rootScope, $cookies, $q, $location, $modal, eeBack, eeAuth) ->

  ## SETUP
  _inputDefaults =
    productsPerPage:  24
    page:             null
    search:           null
    order:            null
    range:
      min:            null
      max:            null
    category:         null
    categoryArray: [
      'Accessories'
      'Arts & Crafts'
      'Artwork'
      'Bed & Bath'
      'Electronics'
      'Furniture'
      'Health & Beauty'
      'Home Decor'
      'Jewelry'
      'Kitchen'
      'Outdoor'
      'Pet Supplies'
    ]
    rangeArray: [
      { min: 0,     max: 2500   },
      { min: 2500,  max: 5000   },
      { min: 5000,  max: 10000  },
      { min: 10000, max: 20000  },
      { min: 20000, max: null   }
    ]

  ## PRIVATE EXPORT DEFAULTS
  _data =
    products:   []
    inputs:     _inputDefaults
    searching:  false

  ## PRIVATE FUNCTIONS
  _formQuery = () ->
    query = {}
    if _data.inputs.page      then query.page       = _data.inputs.page
    if _data.inputs.range.min then query.min        = _data.inputs.range.min
    if _data.inputs.range.max then query.max        = _data.inputs.range.max
    if _data.inputs.search    then query.search     = _data.inputs.search
    if _data.inputs.category  then query.categories = [ _data.inputs.category ] else query.categories = []
    if _data.inputs.order     then query.order      = _data.inputs.order
    query

  _runQuery = () ->
    deferred = $q.defer()
    # if searching then avoid simultaneous calls to API
    if !!_data.searching then return _data.searching
    _data.searching = deferred.promise
    eeBack.productsGET $cookies.loginToken, _formQuery()
    .then (products) ->
      _data.products = products
      deferred.resolve _data.products
    .catch (err) -> deferred.reject err
    .finally () ->
      _data.searching = false
    deferred.promise

  _updateProduct = (newProduct) ->
    assignKey = (key, newProduct, oldProduct) -> if !!key and !!newProduct[key] then oldProduct[key] = newProduct[key]
    updateIfMatch = (n) ->
      oldProduct = _data.products[n]
      if !!oldProduct and oldProduct.id is newProduct.id
        console.log 'updating', n, oldProduct
        assignKey(key, newProduct, oldProduct) for key in Object.keys(oldProduct)
        return true
    updateIfMatch n for n in [0.._data.products.length]
    return false

  ## EXPORTS
  data: _data
  fns:
    search: () ->
      _data.inputs.page = 1
      _runQuery()
    incrementPage: () ->
      _data.inputs.page = if _data.inputs.page < 1 then 2 else _data.inputs.page + 1
      _runQuery()
    decrementPage: () ->
      _data.inputs.page = if _data.inputs.page < 2 then 1 else _data.inputs.page - 1
      _runQuery()
    setCategory: (category) ->
      _data.inputs.page = 1
      _data.inputs.category = if _data.inputs.category is category then null else category
      _runQuery()
    setRange: (range) ->
      range = range || {}
      _data.inputs.page = 1
      if _data.inputs.range.min is range.min and _data.inputs.range.max is range.max
        _data.inputs.range.min = null
        _data.inputs.range.max = null
      else
        _data.inputs.range.min = range.min
        _data.inputs.range.max = range.max
      _runQuery()
    setOrder: (order) ->
      _data.inputs.page = 1
      _data.inputs.order = if _data.inputs.order is order then null else order
      _runQuery()
    updateProduct: (product) ->
      console.log 'new', product
      _updateProduct product
