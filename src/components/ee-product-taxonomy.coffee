angular.module 'ee-product-taxonomy', []

angular.module('ee-product-taxonomy').directive "eeProductTaxonomy", (eeAuth, eeBack, eeModal) ->
  templateUrl: 'components/ee-product-taxonomy.html'
  restrict: 'E'
  scope:
    product: '='
    taxonomies: '='
  link: (scope, ele, attrs) ->
    scope.product.updating = false

    scope.taxonomy =
      current:
        lwh: 'in.'
        weight: 'lbs'
      options:
        lwh: ['in.','ft','yds','mm', 'cm', 'm']
        weight: ['oz','lbs','g','kg']

    scope.setTaxonomyDropdownLWH    = (opt) -> scope.taxonomy.current.lwh = opt
    scope.setTaxonomyDropdownWeight = (opt) -> scope.taxonomy.current.weight = opt

    scope.open = () ->
      scope.product.reading = true
      eeBack.productGET scope.product.id, eeAuth.fns.getToken()
      .then (prod) -> eeModal.fns.openProductModal prod
      .catch (err) -> console.error err
      .finally () ->  scope.product.reading = false

    scope.setHidden = (bool) ->
      console.log 'bool', bool
      scope.product.reading = true
      eeBack.productPUT { id: scope.product.id, hide_from_catalog: bool }, eeAuth.fns.getToken()
      .then (prod) -> scope.product.hide_from_catalog = bool
      .catch (err) ->
        console.error err
        scope.product.hide_from_catalog = !bool
      .finally () ->  scope.product.reading = false

    scope.updateTaxonomy = () ->
      scope.product.updating = true
      scope.product.succeeded = false
      eeBack.productPUT
        id:       scope.product.id
        style:    scope.product.style
        color:    scope.product.color
        material: scope.product.material
        length:   scope.product.length
        width:    scope.product.width
        height:   scope.product.height
      , eeAuth.fns.getToken()
      .then (prod) ->
        scope.product = prod
        scope.product.succeeded = true
      .catch (err) -> console.error err
      .finally () ->  scope.product.updating = false
    return
