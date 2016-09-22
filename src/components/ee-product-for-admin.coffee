angular.module 'ee-product-for-admin', []

angular.module('ee-product-for-admin').directive "eeProductForAdmin", ($state, eeAuth, eeBack, eeModal, eeProduct, eeProducts) ->
  templateUrl: 'components/ee-product-for-admin.html'
  restrict: 'EA'
  scope:
    product:    '='
    styles:     '='
    colors:     '='
    materials:  '='
    compact:    '='
  link: (scope, ele, attrs) ->
    scope.$state = $state
    scope.compact = false
    scope.product.updating = false

    scope.taxonomy =
      current:
        lwh: 'in.'
        weight: 'lbs'
      options:
        lwh: ['in.','ft','yds','mm','cm','m']
        weight: ['lbs','oz','g','kg']

    convertLengths = (ratio) ->
      scope.product.length  = if scope.product.length is '' then null else ratio * scope.product.length
      scope.product.width   = if scope.product.width  is '' then null else ratio * scope.product.width
      scope.product.height  = if scope.product.height is '' then null else ratio * scope.product.height

    convertWeight = (ratio) ->
      scope.product.weight  = if scope.product.weight is '' then null else ratio * scope.product.weight

    convertUnits = () ->
      if scope.taxonomy.current.lwh isnt 'in.'
        if scope.taxonomy.current.lwh is 'ft'     then convertLengths 12.0
        if scope.taxonomy.current.lwh is 'yds'    then convertLengths 36.0
        if scope.taxonomy.current.lwh is 'mm'     then convertLengths 0.0393701
        if scope.taxonomy.current.lwh is 'cm'     then convertLengths 0.393701
        if scope.taxonomy.current.lwh is 'm'      then convertLengths 39.3701
        scope.taxonomy.current.lwh = 'in.'
      if scope.taxonomy.current.weight isnt 'lbs'
        if scope.taxonomy.current.weight is 'oz'  then convertWeight 0.0625
        if scope.taxonomy.current.weight is 'g'   then convertWeight 28.3495
        if scope.taxonomy.current.weight is 'kg'  then convertWeight 0.0283495
        scope.taxonomy.current.weight = 'lbs'


    scope.setTaxonomyDropdownLWH    = (opt) -> scope.taxonomy.current.lwh = opt
    scope.setTaxonomyDropdownWeight = (opt) -> scope.taxonomy.current.weight = opt

    scope.open = () ->
      scope.product.reading = true
      eeBack.fns.productGET scope.product.id, eeAuth.fns.getToken()
      .then (prod) -> eeModal.fns.openProductModal prod
      .catch (err) -> console.error err
      .finally () ->  scope.product.reading = false

    # TODO redo with sku.hide_from_catalog
    # scope.setHidden = (bool) ->
    #   scope.product.reading = true
    #   eeBack.fns.productPUT { id: scope.product.id, hide_from_catalog: bool }, eeAuth.fns.getToken()
    #   .then (prod) -> scope.product.hide_from_catalog = bool
    #   .catch (err) ->
    #     console.error err
    #     scope.product.hide_from_catalog = !bool
    #   .finally () ->  scope.product.reading = false

    scope.updateTaxonomy = () ->
      scope.product.updating = true
      scope.product.succeeded = false
      convertUnits()
      product = {}
      if !!scope.product.id       then product.id       = scope.product.id
      if !!scope.product.style    then product.style    = scope.product.style
      if !!scope.product.color    then product.color    = scope.product.color
      if !!scope.product.material then product.material = scope.product.material
      if !!scope.product.length   then product.length   = scope.product.length
      if !!scope.product.width    then product.width    = scope.product.width
      if !!scope.product.height   then product.height   = scope.product.height
      console.log 'product', product
      eeBack.fns.productPUT product, eeAuth.fns.getToken()
      .then (prod) ->
        scope.product = prod
        scope.product.succeeded = true
      .catch (err) -> console.error err
      .finally () ->  scope.product.updating = false

    scope.addVal = (attr, val) ->
      if !scope.product[attr] then scope.product[attr] = ''
      if scope.product[attr] isnt '' then scope.product[attr] += ', '
      scope.product[attr] += val

    scope.updateText = () ->
      eeProduct.fns.update scope.product, ['title', 'content'], ['selection_text', 'length', 'width', 'height', 'weight']

    scope.setActiveProduct = () -> eeProducts.fns.setActiveProduct scope.product

    return
