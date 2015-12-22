'use strict'

angular.module('app.core').controller 'userCtrl', ($rootScope, $stateParams, eeUser) ->

  user = this
  user.id = $stateParams.id

  user.reading = true
  eeUser.fns.get user.id
  .then (res) ->
    user.user = res
    createCharts user.user
  .finally () -> user.reading = false

  createCharts = (u) ->
    filters = [{
      operator: 'eq',
      property_name: 'user',
      property_value: u.tr_uuid
    }]
    for prop in ['eeosk.com', 'localhost', 'herokuapp']
      filters.push {
        operator: 'not_contains',
        property_name: 'referer',
        property_value: prop
      }
    for prop in ['username', 'domain']
      if user.user[prop] then filters.push {
        operator: 'not_contains',
        property_name: 'referer',
        property_value: u[prop]
      }

    Keen.ready () ->

      storeCount = new Keen.Query 'count', {
        eventCollection: 'store'
        filters: filters
        groupBy: ['referer']
        interval: 'daily',
        timeframe: 'this_7_days',
        timezone: 'US/Pacific'
      }

      $rootScope.keenio.draw storeCount, document.getElementById('stacked_chart'), {
        title: 'Last 7 days'
        chartType: 'columnchart'
        isStacked: true
        legend: position: 'none'
      }

      storePie = new Keen.Query 'count', {
        eventCollection: 'store'
        filters: filters
        groupBy: ['referer']
        timeframe: 'this_14_days',
        timezone: 'US/Pacific'
      }

      $rootScope.keenio.draw storePie, document.getElementById('pie_chart'), {
        title: '14-day Visits'
        chartType: 'piechart'
      }

  return
