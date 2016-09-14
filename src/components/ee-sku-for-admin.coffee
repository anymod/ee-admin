angular.module 'ee-sku-for-admin', []

angular.module('ee-sku-for-admin').directive "eeSkuForAdmin", ($rootScope, $state, eeAuth, eeBack, eeProduct, eeModal, categories) ->
  templateUrl: 'components/ee-sku-for-admin.html'
  restrict: 'EA'
  replace: true
  scope:
    sku:        '='
    styles:     '='
    colors:     '='
    materials:  '='
    content:    '='
    externalId: '='
    categoryId: '='
  link: (scope, ele, attrs) ->
    scope.$state = $state
    scope.categories = categories

    resetCategory = () ->
      for cat in categories
        if cat.id is scope.categoryId then scope.category = cat
    resetCategory()

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

    scope.dimensionGuesses = []
    dimensionString = ('' + scope.content + ' | ' + scope.sku.selection_text)
      .replace(/-/g, '').replace(/inch(es)?/g, '"').replace(/center/g, '')
      .replace(/1\/4/g, '.25').replace(/1\/2/g, '.5').replace(/3\/4/g, '.75')
      .replace(/1\/8/g, '.125').replace(/3\/8/g, '.375').replace(/5\/8/g, '.625').replace(/7\/8/g, '.875')
    matches = dimensionString.replace(/ +/g, '').match(/\d[\d\.\- \/]*/g) || [] #/
    for match in matches
      m = parseFloat(match)
      if m < 1000 and m > 0 and scope.dimensionGuesses.indexOf(m) is -1
        scope.dimensionGuesses.push m
    scope.setDimension = (dim, guess) -> scope.sku[dim] = guess

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

    scope.swapDimensions = (a, b) ->
      c = angular.copy scope.sku[a]
      scope.sku[a] = scope.sku[b]
      scope.sku[b] = c

    scope.copySku = () -> $rootScope.$broadcast 'copy:sku', { sku: scope.sku, categoryId: scope.categoryId }
    scope.$on 'copy:sku', (e, data) -> scope.copiedData = data
    scope.pasteSkuDimensions = () ->
      if scope.copiedData
        scope.sku[attr] = scope.copiedData.sku[attr] for attr in ['length', 'width', 'height', 'weight']

    scope.pasteSkuTags = () ->
      if scope.copiedData
        scope.sku[attr] = scope.copiedData.sku[attr] for attr in ['tags']
        if scope.copiedData.categoryId > 0
          scope.categoryId = parseInt(scope.copiedData.categoryId)
          resetCategory()

    scope.guessDimensions = () ->
      matchL = /\d[\d\.\- ]+.{0,3}([ "(]*[LlDd][^b])/g
      matchW = /\d[\d\.\- ]+.{0,3}([ "(]*[Ww])/g
      matchH = /\d[\d\.\- ]+.{0,3}([ "(]*[Hh])/g
      guessL = parseFloat(dimensionString.match(matchL)?[0].replace(/[^\d\.-]/g, ''))
      guessW = parseFloat(dimensionString.match(matchW)?[0].replace(/[^\d\.-]/g, ''))
      guessH = parseFloat(dimensionString.match(matchH)?[0].replace(/[^\d\.-]/g, ''))
      if guessL > 1 then scope.sku.length = guessL
      if guessW > 1 then scope.sku.width  = guessW
      if guessH > 1 then scope.sku.height = guessH
      return if scope.sku.length? || scope.sku.width? || scope.sku.height?
      matchLWH = /\d.*[xX].*[xX].*\d/g
      guessLWH = dimensionString.match(matchLWH)?[0].replace(/[^\d\.-x]/g, '').split(/x/g)
      if guessLWH?.length > 0
        scope.sku.length = parseFloat(guessLWH[0]?.replace(/[^\d\.-]/g, ''))
        scope.sku.width  = parseFloat(guessLWH[1]?.replace(/[^\d\.-]/g, ''))
        scope.sku.height = parseFloat(guessLWH[2]?.replace(/[^\d\.-]/g, ''))
      return

    scope.setTaxonomyDropdownLWH    = (opt) -> scope.taxonomy.current.lwh = opt
    scope.setTaxonomyDropdownWeight = (opt) -> scope.taxonomy.current.weight = opt

    scope.setCategoryId = (id) ->
      scope.categoryId = parseInt(id)
      resetCategory()

    scope.addTag = (tag) ->
      add = true
      for t in scope.sku.tags
        if t is tag then add = false
      if add then scope.sku.tags.push tag

    scope.removeTag = (tag) ->
      for t, i in scope.sku.tags
        if t is tag then return scope.sku.tags.splice(i, 1)

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

    # TODO replace these methods with direct Sku update
    scope.updateCategoryTags = () ->
      product = {
        id: scope.sku.product_id
        skus: [scope.sku]
      }
      if scope.categoryId then product.category_id = parseInt(scope.categoryId)
      eeProduct.fns.update product, [], ['tags']
      .then (prod) ->
        for sku in prod.skus
          if sku.id is scope.sku.id
            scope.sku[attr] = sku[attr] for attr in Object.keys(sku)
            scope.sku.saved = true

    return
