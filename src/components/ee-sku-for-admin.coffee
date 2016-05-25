angular.module 'ee-sku-for-admin', []

angular.module('ee-sku-for-admin').directive "eeSkuForAdmin", ($state, eeAuth, eeBack, eeProduct, eeModal) ->
  templateUrl: 'components/ee-sku-for-admin.html'
  restrict: 'EA'
  replace: true
  scope:
    sku:        '='
    styles:     '='
    colors:     '='
    materials:  '='
    product:    '='
    externalId: '='
  link: (scope, ele, attrs) ->
    console.log scope.externalId, scope.product
    scope.$state = $state

    scope.sku.updating = false
    scope.showEdit = false
    scope.showEditor = () -> scope.showEdit = true

    scope.taxonomy =
      current:
        lwh: 'in.'
        weight: 'lbs'
      options:
        lwh: ['in.','ft','yds','mm','cm','m']
        weight: ['lbs','oz','g','kg']

    convertLengths = (ratio) ->
      scope.sku.length  = if scope.sku.length is '' then null else ratio * scope.sku.length
      scope.sku.width   = if scope.sku.width  is '' then null else ratio * scope.sku.width
      scope.sku.height  = if scope.sku.height is '' then null else ratio * scope.sku.height

    convertWeight = (ratio) ->
      scope.sku.weight  = if scope.sku.weight is '' then null else ratio * scope.sku.weight

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
      scope.sku.reading = true
      eeBack.fns.skuGET scope.sku.id, eeAuth.fns.getToken()
      .then (prod) -> eeModal.fns.openSkuModal prod
      .catch (err) -> console.error err
      .finally () ->  scope.sku.reading = false

    scope.setHidden = (bool) ->
      scope.sku.reading = true
      eeBack.fns.skuPUT { id: scope.sku.id, hide_from_catalog: bool }, eeAuth.fns.getToken()
      .then (prod) -> scope.sku.hide_from_catalog = bool
      .catch (err) ->
        console.error err
        scope.sku.hide_from_catalog = !bool
      .finally () ->  scope.sku.reading = false

    scope.updateTaxonomy = () ->
      scope.sku.updating = true
      scope.sku.succeeded = false
      convertUnits()
      sku = {}
      if !!scope.sku.id       then sku.id       = scope.sku.id
      if !!scope.sku.style    then sku.style    = scope.sku.style
      if !!scope.sku.color    then sku.color    = scope.sku.color
      if !!scope.sku.material then sku.material = scope.sku.material
      if !!scope.sku.length   then sku.length   = scope.sku.length
      if !!scope.sku.width    then sku.width    = scope.sku.width
      if !!scope.sku.height   then sku.height   = scope.sku.height
      eeBack.fns.skuPUT sku, eeAuth.fns.getToken()
      .then (prod) ->
        scope.sku = prod
        scope.sku.succeeded = true
      .catch (err) -> console.error err
      .finally () ->  scope.sku.updating = false

    scope.addVal = (attr, val) ->
      if !scope.sku[attr] then scope.sku[attr] = ''
      if scope.sku[attr] isnt '' then scope.sku[attr] += ', '
      scope.sku[attr] += val

    # TODO replace these methods with direct Sku update
    scope.updatePricing = () ->
      product = {
        id: scope.sku.product_id
        skus: [scope.sku]
      }
      eeProduct.fns.update product, [], ['baseline_price', 'shipping_price', 'auto_pricing']
      .then (prod) ->
        for sku in prod.skus
          if sku.id is scope.sku.id
            scope.sku[attr] = sku[attr] for attr in Object.keys(sku)
            scope.sku.saved = true
        scope.showEdit = false

    # TODO replace these methods with direct Sku update
    scope.toggleHidden = () ->
      scope.sku.hide_from_catalog = !scope.sku.hide_from_catalog
      product = {
        id: scope.sku.product_id
        skus: [{
          id: scope.sku.id
          hide_from_catalog: scope.sku.hide_from_catalog
        }]
      }
      eeProduct.fns.update product, [], ['hide_from_catalog']
      .then (prod) ->
        for sku in prod.skus
          if sku.id is scope.sku.id
            scope.sku[attr] = sku[attr] for attr in Object.keys(sku)
            scope.sku.saved = true

    # TODO replace these methods with direct Sku update
    scope.updateStyleColorMaterial = () ->
      product = {
        id: scope.sku.product_id
        skus: [scope.sku]
      }
      eeProduct.fns.update product, [], ['style', 'color', 'material']
      .then (prod) ->
        for sku in prod.skus
          if sku.id is scope.sku.id
            scope.sku[attr] = sku[attr] for attr in Object.keys(sku)
            scope.sku.saved = true

    return
