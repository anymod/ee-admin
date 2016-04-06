'use strict'

angular.module('app.core').factory 'eeBack', ($http, $q, eeBackUrl, eeTidyUrl, eeAdminUrl) ->

  _handleError = (deferred, data, status) ->
    if status is 0 then deferred.reject 'Connection error' else deferred.reject data

  _makeRequest = (req) ->
    deferred = $q.defer()
    $http(req)
      .success (data, status) -> deferred.resolve data
      .error (data, status) -> _handleError deferred, data, status
    deferred.promise

  _formQueryString = (query) ->
    if !query then return ''
    keys = Object.keys(query)
    parts = []
    addQuery = (key) -> parts.push(encodeURIComponent(key) + '=' + encodeURIComponent(query[key]))
    addQuery(key) for key in keys
    '?' + parts.join('&')

  fns:

    tokenPOST: (token) ->
      _makeRequest {
        method: 'POST'
        url: eeBackUrl + 'token'
        headers: authorization: token
      }

    # tokenPOST: (token) -> _tokenPOST token

    authPOST: (email, password) ->
      _makeRequest {
        method: 'POST'
        url: eeBackUrl + 'auth'
        headers: authorization: 'Basic ' + email + ':' + password
      }

    usersGET: (token, query) ->
      _makeRequest {
        method: 'GET'
        url: eeBackUrl + 'admin/users' + _formQueryString(query)
        headers: authorization: token
      }

    userGET: (id, token) ->
      _makeRequest {
        method: 'GET'
        url: eeBackUrl + 'admin/users/' + id
        headers: authorization: token
      }

    userEmailGET: (id, token) ->
      _makeRequest {
        method: 'GET'
        url: eeBackUrl + 'admin/users/' + id + '/email'
        headers: authorization: token
      }

    productsGET: (token, query) ->
      _makeRequest {
        method: 'GET'
        url: eeBackUrl + 'admin/products' + _formQueryString(query)
        headers: authorization: token
      }

    productGET: (id, token) ->
      _makeRequest {
        method: 'GET'
        url: eeBackUrl + 'admin/products/' + id
        headers: authorization: token
      }

    productPUT: (product, token) ->
      _makeRequest {
        method: 'PUT'
        url: eeBackUrl + 'admin/products/' + product.id
        headers: authorization: token
        data: product
      }

    collectionsGET: (token, query) ->
      _makeRequest {
        method: 'GET'
        url: eeBackUrl + 'admin/collections' + _formQueryString(query)
        headers: authorization: token
      }

    leadsGET: (token, query) ->
      _makeRequest {
        method: 'GET'
        url: eeTidyUrl + 'leads' + _formQueryString(query)
        headers: authorization: token
      }

    leadGET: (id, token) ->
      _makeRequest {
        method: 'GET'
        url: eeTidyUrl + 'leads/' + id
        headers: authorization: token
      }

    leadPUT: (lead, token) ->
      _makeRequest {
        method: 'PUT'
        url: eeTidyUrl + 'leads/' + lead.id
        headers: authorization: token
        data: lead
      }

    taxonomiesGET: (token) ->
      _makeRequest {
        method: 'GET'
        url: eeBackUrl + 'admin/taxonomies'
        headers: authorization: token
      }

    taxonomyPOST: (data, token) ->
      _makeRequest {
        method: 'POST'
        url: eeBackUrl + 'admin/taxonomies'
        headers: authorization: token
        data: data
      }

    taxonomyDELETE: (id, token) ->
      _makeRequest {
        method: 'DELETE'
        url: eeBackUrl + 'admin/taxonomies/' + id
        headers: authorization: token
      }

    tracksGET: (token, query) ->
      _makeRequest {
        method: 'GET'
        url: eeBackUrl + 'admin/tracks' + _formQueryString(query)
        headers: authorization: token
      }

    trackGET: (id, token) ->
      _makeRequest {
        method: 'GET'
        url: eeBackUrl + 'admin/tracks/' + id
        headers: authorization: token
      }

    trackPUT: (track, token) ->
      _makeRequest {
        method: 'PUT'
        url: eeBackUrl + 'admin/tracks/' + track.id
        headers: authorization: token
        data: track
      }

    activityPOST: (activity, token) ->
      _makeRequest {
        method: 'POST'
        url: eeBackUrl + 'admin/activities'
        headers: authorization: token
        data: activity
      }

    activityPUT: (activity, token) ->
      _makeRequest {
        method: 'PUT'
        url: eeBackUrl + 'admin/activities/' + activity.id
        headers: authorization: token
        data: activity
      }

    stepPOST: (step, token) ->
      _makeRequest {
        method: 'POST'
        url: eeBackUrl + 'admin/steps'
        headers: authorization: token
        data: step
      }

    stepPUT: (step, token) ->
      _makeRequest {
        method: 'PUT'
        url: eeBackUrl + 'admin/steps/' + step.id
        headers: authorization: token
        data: step
      }

    processingStatusGET: () ->
      _makeRequest {
        method: 'GET'
        url: eeAdminUrl + 'processing/status'
      }

    processingUpdatePOST: () ->
      _makeRequest {
        method: 'POST'
        url: eeAdminUrl + 'processing/update'
      }

    processingElasticsearchPOST: () ->
      _makeRequest {
        method: 'POST'
        url: eeAdminUrl + 'processing/elasticsearch'
      }
