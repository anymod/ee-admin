angular.module 'ee-template-admin', []

angular.module('ee-template-admin').directive "eeTemplateAdmin", (eeAuth, eeBack, eeModal) ->
  templateUrl: 'components/ee-template-admin.html'
  restrict: 'E'
  scope:
    template:   '='
    styles:     '='
    colors:     '='
    materials:  '='
    compact:    '='
  link: (scope, ele, attrs) ->
    scope.template.updating = false

    scope.taxonomy =
      current:
        lwh: 'in.'
        weight: 'lbs'
      options:
        lwh: ['in.','ft','yds','mm','cm','m']
        weight: ['lbs','oz','g','kg']

    convertLengths = (ratio) ->
      scope.template.length  = if scope.template.length is '' then null else ratio * scope.template.length
      scope.template.width   = if scope.template.width  is '' then null else ratio * scope.template.width
      scope.template.height  = if scope.template.height is '' then null else ratio * scope.template.height

    convertWeight = (ratio) ->
      scope.template.weight  = if scope.template.weight is '' then null else ratio * scope.template.weight

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
      scope.template.reading = true
      eeBack.templateGET scope.template.id, eeAuth.fns.getToken()
      .then (prod) -> eeModal.fns.openTemplateModal prod
      .catch (err) -> console.error err
      .finally () ->  scope.template.reading = false

    scope.setHidden = (bool) ->
      scope.template.reading = true
      eeBack.templatePUT { id: scope.template.id, hide_from_catalog: bool }, eeAuth.fns.getToken()
      .then (prod) -> scope.template.hide_from_catalog = bool
      .catch (err) ->
        console.error err
        scope.template.hide_from_catalog = !bool
      .finally () ->  scope.template.reading = false

    scope.updateTaxonomy = () ->
      scope.template.updating = true
      scope.template.succeeded = false
      convertUnits()
      template = {}
      if !!scope.template.id       then template.id       = scope.template.id
      if !!scope.template.style    then template.style    = scope.template.style
      if !!scope.template.color    then template.color    = scope.template.color
      if !!scope.template.material then template.material = scope.template.material
      if !!scope.template.length   then template.length   = scope.template.length
      if !!scope.template.width    then template.width    = scope.template.width
      if !!scope.template.height   then template.height   = scope.template.height
      console.log 'template', template
      eeBack.templatePUT template, eeAuth.fns.getToken()
      .then (prod) ->
        scope.template = prod
        scope.template.succeeded = true
      .catch (err) -> console.error err
      .finally () ->  scope.template.updating = false

    scope.addVal = (attr, val) ->
      if !scope.template[attr] then scope.template[attr] = ''
      if scope.template[attr] isnt '' then scope.template[attr] += ', '
      scope.template[attr] += val

    return
