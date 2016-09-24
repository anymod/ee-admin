'use strict'

angular.module('app.core').factory 'eeProducts', ($rootScope, $q, $filter, eeBack, eeAuth, eeModal, eeProduct, categories, tagTree) ->

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
    filter:       null
    categoryArray: categories
    rangeArray: [
      { min: 0,     max: 2500   },
      { min: 2500,  max: 5000   },
      { min: 5000,  max: 10000  },
      { min: 10000, max: 20000  },
      { min: 20000, max: null   }
    ]
    orderArray: [
      { order: 'cd',  html: 'Newest' },
      { order: 'ud',  html: 'Updated' },
      { order: 'pa',  html: '$-$$$' },
      { order: 'pd',  html: '$$$-$' },
      { order: 'ta',  html: 'A-Z' },
      { order: 'td',  html: 'Z-A' },
      { order: 'shipd', html: '% Shipping <i class="fa fa-sort-amount-desc"></i>' },
      { order: 'shipa', html: '% Shipping <i class="fa fa-sort-amount-asc"></i>' },
      # { order: 'discd', html: '% off <i class="fa fa-sort-amount-desc"></i>' },
      # { order: 'disca', html: '% off <i class="fa fa-sort-amount-asc"></i>' },
      { order: 'eeprofd', html: '% ee profit <i class="fa fa-sort-amount-desc"></i>' },
      { order: 'eeprofa', html: '% ee profit <i class="fa fa-sort-amount-asc"></i>' },
      # { order: 'sellprofd', html: 'Seller profit $$-$' },
      # { order: 'sellprofa', html: 'Seller profit $-$$' }
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
    activeProduct: {}
    activeTagTab: 0

  ## PRIVATE FUNCTIONS
  _clearSection = (section) ->
    _data.products = []
    _data[section].count    = 0

  _formQuery = (section) ->
    query = {}
    query.size = _data[section].inputs.perPage
    if _data[section].inputs.page         then query.page           = _data[section].inputs.page
    if _data[section].inputs.search       then query.search         = _data[section].inputs.search
    if _data[section].inputs.range.min    then query.min_price      = _data[section].inputs.range.min
    if _data[section].inputs.range.max    then query.max_price      = _data[section].inputs.range.max
    if _data[section].inputs.order.order  then query.order          = _data[section].inputs.order.order
    if _data[section].inputs.supplier_id  then query.supplier_id    = _data[section].inputs.supplier_id
    if _data[section].inputs.category     then query.category_ids   = [_data[section].inputs.category.id]
    if _data[section].inputs.filter       then query[_data[section].inputs.filter] = 'true'
    query.uncustomized = 'true'
    query

  _runQuery = (section, queryPromise) ->
    if _data[section].reading then return
    _data[section].reading = true
    queryPromise
    .then (res) ->
      { rows, count, took } = res
      _data[section].products = rows
      _data[section].count = count
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
    _data.search.inputs.order = {}
    _data.search.inputs.search = term
    _data.search.inputs.page = 1
    _runSection 'search'

  _searchWithIdentifier = (identifier) ->
    _data.search.inputs.order = {}
    _data.search.inputs.search = term
    _data.search.inputs.page = 1
    _runSection 'search'

  _addProductModal = (product, type) ->
    product.err = null
    eeModal.fns.openProductModal product, type
    return

  _handleKeydown = (e) ->
    if e.keyCode is 37 or e.keyCode is 38 then $rootScope.$apply _prevActiveProduct()
    if e.keyCode is 39 or e.keyCode is 40 then $rootScope.$apply _nextActiveProduct()

  _setActiveProduct = (product) ->
    return _data.activeProduct = {} unless product?.skus?.length > 0
    product.shown = product.skus.map((sku) -> sku.discontinued || sku.hide_from_catalog).indexOf(false) > -1
    angular.element(document).off('keydown', _handleKeydown)
    if product?.id then angular.element(document).on('keydown', _handleKeydown)
    _data.activeProduct = product
    for tag, i in Object.keys tagTree
      if _activeProductHasTag(tag, 1) then return _data.activeTagTab = i

  _saveActiveProductTags = () ->
    return unless _data.activeProduct?.skus?.length > 0
    _data.activeProduct.saved = false
    for sku in _data.activeProduct?.skus
      sku[attr] = _data.activeProduct.skus[0][attr] for attr in ['tags1', 'tags2', 'tags3']
    eeProduct.fns.update _data.activeProduct, [], ['tags1', 'tags2', 'tags3']
    .then (prod) -> _data.activeProduct.saved = true
    .catch (err) -> _data.activeProduct.alert = err

  _activeProductIndex = () ->
    for product,i in _data.search.products
      if product.id is _data.activeProduct.id then return i
    null

  _prevActiveProduct = () ->
    return false unless _data.activeProduct?.id
    index = _activeProductIndex() || 0
    _setActiveProduct _data.search.products[Math.max(index - 1, 0)]

  _nextActiveProduct = () ->
    return false unless _data.activeProduct?.id
    index = _activeProductIndex() || 0
    _setActiveProduct _data.search.products[Math.min(index + 1, _data.search.products.length)]

  _activeProductHasTag = (tag, level) ->
    return false unless _data.activeProduct?.skus?.length > 0
    _data.activeProduct.skus[0]['tags' + level]?.indexOf($filter('urlText')(tag)) > -1

  _addTagToActiveProduct = (tag, level) ->
    return unless tag and level
    newTags = []
    _data.activeProduct.skus[0]?['tags' + level].push tag
    for t in _data.activeProduct.skus[0]?['tags' + level]
      if newTags.indexOf(t) < 0 then newTags.push t
    _data.activeProduct.skus[0]?['tags' + level] = newTags

  _removeTagFromActiveProduct = (tag, level, opts) ->
    return unless tag and level
    opts ||= {}
    newTags = []
    tag = $filter('urlText')(tag)
    for t in _data.activeProduct.skus[0]?['tags' + level]
      if t isnt tag then newTags.push t
    _data.activeProduct.skus[0]?['tags' + level] = newTags
    if opts.save then _saveActiveProductTags()

  _toggleTagForActiveProduct = (tag, level) ->
    return unless tag and level
    if _activeProductHasTag tag, level then _removeTagFromActiveProduct tag, level else _addTagToActiveProduct tag, level

  _toggleTagsForActiveProduct = (tagset, opts) ->
    return unless tagset.tag1 and tagset.tag2 and _data.activeProduct?.skus?.length > 0
    opts ||= {}
    tag1 = $filter('urlText')(tagset.tag1)
    tag2 = $filter('urlText')(tagset.tag2)
    tag3 = $filter('urlText')(tagset.tag3)
    _addTagToActiveProduct tag1, 1
    if !tag3 then return _toggleTagForActiveProduct tag2, 2
    _addTagToActiveProduct tag2, 2
    _toggleTagForActiveProduct tag3, 3
    if opts.save then _saveActiveProductTags()


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
    toggleFilter: (filter, section) ->
      return if !filter
      _data[section].inputs.page    = 1
      _data[section].inputs.filter  = if filter is _data[section].inputs.filter then null else filter
      _runSection section
    addProductModal: _addProductModal
    setActiveProduct: _setActiveProduct
    toggleTagsForActiveProduct: _toggleTagsForActiveProduct
    removeTagFromActiveProduct: _removeTagFromActiveProduct
