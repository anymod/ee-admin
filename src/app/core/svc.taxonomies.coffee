'use strict'

angular.module('app.core').factory 'eeTaxonomies', ($q, $filter, eeBack, eeAuth) ->

  _data =
    taxonomies:
      all: []
      styles: []
      colors: []
      materials: []

  _sortTaxonomy = (taxonomy) ->
    if taxonomy.attribute is 'style'    then _data.taxonomies.styles.push taxonomy
    if taxonomy.attribute is 'color'    then _data.taxonomies.colors.push taxonomy
    if taxonomy.attribute is 'material' then _data.taxonomies.materials.push taxonomy

  _sortTaxonomies = () ->
    _data.taxonomies.styles = []
    _data.taxonomies.colors = []
    _data.taxonomies.materials = []
    _sortTaxonomy t for t in _data.taxonomies.all
    _data.taxonomies.styles = $filter('orderBy')(_data.taxonomies.styles, 'value')
    _data.taxonomies.colors = $filter('orderBy')(_data.taxonomies.colors, 'value')
    _data.taxonomies.materials = $filter('orderBy')(_data.taxonomies.materials, 'value')

  _removeTaxonomy = (id) ->
    taxonomies = []
    (taxonomies.push taxonomy unless taxonomy.id is id) for taxonomy in _data.taxonomies.all
    _data.taxonomies.all = taxonomies
    _sortTaxonomies()

  _search = () ->
    deferred = $q.defer()
    if !!_data.reading then return _data.reading
    _data.reading = deferred.promise
    eeBack.taxonomiesGET eeAuth.fns.getToken()
    .then (res) ->
      _data.taxonomies.all = res
      _sortTaxonomies()
      deferred.resolve _data.taxonomies
    .catch (err) ->
      console.error err
      deferred.reject err
    .finally () ->
      _data.reading = false
    deferred.promise

  _createTaxonomy = (attribute, value) ->
    deferred = $q.defer()
    if !!_data.creating then return _data.creating
    _data.creating = deferred.promise
    eeBack.taxonomyPOST { attribute: attribute, value: value }, eeAuth.fns.getToken()
    .then (res) ->
      _data.taxonomies.all.push res
      _sortTaxonomies()
      deferred.resolve res
    .catch (err) ->
      console.error err
      deferred.reject err
    .finally () ->
      _data.creating = false
    deferred.promise

  _destroyTaxonomy = (taxonomy) ->
    taxonomy.destroying = true
    deferred = $q.defer()
    if !!_data.destroying then return _data.destroying
    _data.destroying = deferred.promise
    eeBack.taxonomyDELETE taxonomy.id, eeAuth.fns.getToken()
    .then (res) ->
      _removeTaxonomy taxonomy.id
      deferred.resolve res
    .catch (err) ->
      console.error err
      taxonomy.destroying = false
      deferred.reject err
    .finally () ->
      _data.destroying = false
    deferred.promise


  data: _data
  fns:
    search: _search
    createTaxonomy: _createTaxonomy
    destroyTaxonomy: _destroyTaxonomy
