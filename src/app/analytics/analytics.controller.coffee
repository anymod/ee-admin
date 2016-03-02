'use strict'

angular.module('app.core').controller 'analyticsCtrl', ($rootScope) ->

  analytics = this

  chartOptions =
    titlePosition: 'none'
    width: '100%'
    height: '200px'
    chartArea:
      width: '90%'
      height: '90%'
    isStacked: true
    legend: position: 'none'

  tableOptions =
    sortColumn: 1
    sortAscending: false
    width: '110%'
    height: '450px'

  Keen.ready () ->

    # DAILY ACTIVE CUSTOMERS
    dac = new Keen.Query 'count_unique', {
      eventCollection: 'store',
      filters: [{
        operator: 'eq',
        property_name: 'self',
        property_value: false
      },{
        operator: 'exists'
        property_name: 'host',
        property_value: true
      }],
      interval: 'daily'
      targetProperty: '_ee',
      groupBy: 'host',
      timeframe: 'this_30_days',
      timezone: 'US/Pacific'
    }
    $rootScope.keenio.draw dac, document.getElementById('dac'), {
      chartType: 'columnchart'
      chartOptions: chartOptions
    }
    # DAILY ACTIVE STORES
    dac_store = new Keen.Query 'count_unique', {
      eventCollection: 'store',
      filters: [{
        operator: 'eq',
        property_name: 'self',
        property_value: false
      },{
        operator: 'exists'
        property_name: 'host',
        property_value: true
      }],
      interval: 'daily'
      targetProperty: 'host',
      groupBy: 'host',
      timeframe: 'this_30_days',
      timezone: 'US/Pacific'
    }
    $rootScope.keenio.draw dac_store, document.getElementById('dac_store'), {
      chartType: 'columnchart'
      chartOptions: chartOptions
    }

    # DAILY ACTIVE SELLERS
    das = new Keen.Query 'count_unique', {
      eventCollection: 'builder',
      interval: 'daily',
      targetProperty: 'username',
      groupBy: 'username',
      timeframe: 'this_30_days',
      timezone: 'US/Pacific'
    }
    $rootScope.keenio.draw das, document.getElementById('das'), {
      chartType: 'columnchart',
      chartOptions: chartOptions
    }
    das_activity = new Keen.Query 'count_unique', {
      eventCollection: 'builder',
      interval: 'daily',
      targetProperty: 'keen.id',
      groupBy: 'username',
      timeframe: 'this_30_days',
      timezone: 'US/Pacific'
    }
    $rootScope.keenio.draw das_activity, document.getElementById('das_activity'), {
      chartType: 'columnchart',
      chartOptions: chartOptions
    }

    # MOST ACTIVE SELLERS
    active_sellers = new Keen.Query 'count', {
      eventCollection: 'builder',
      groupBy: 'username',
      timeframe: 'this_14_days',
      timezone: 'US/Pacific'
    }
    $rootScope.keenio.draw active_sellers, document.getElementById('active_sellers'), {
      chartType: 'table',
      chartOptions: tableOptions
    }

    # TOP PERFORMERS
    top_performers = new Keen.Query 'count_unique', {
      eventCollection: 'store',
      filters: [{
        operator: 'eq',
        property_name: 'self',
        property_value: false
      },{
        operator: 'exists'
        property_name: 'host',
        property_value: true
      }],
      targetProperty: '_ee',
      groupBy: 'host',
      timeframe: 'this_14_days',
      timezone: 'US/Pacific'
    }
    top_performers_cutoff = 2
    top_performers_chart = new Keen.Dataviz()
      .el(document.getElementById('top_performers'))
      .chartType 'table'
      .chartOptions tableOptions
      .prepare()
    $rootScope.keenio.run top_performers, (err, res) ->
      if err then return top_performers_chart.error(err.message)
      stores = []
      for store in res.result
        if store.result > top_performers_cutoff then stores.push store
      top_performers_chart.parseRawData({ result: stores }).render()

      # WEEKLY CHECKS
      weekly_checks = new Keen.Query 'count', {
        eventCollection: 'checkbox',
        filters: [{
          operator: 'eq',
          property_name: 'check',
          property_value: true
        }],
        interval: 'daily'
        targetProperty: 'track_title',
        groupBy: 'track_title',
        timeframe: 'this_30_days',
        timezone: 'US/Pacific'
      }
      $rootScope.keenio.draw weekly_checks, document.getElementById('weekly_checks'), {
        chartType: 'columnchart'
        chartOptions: chartOptions
      }

      # TOP STEPS
      top_steps = new Keen.Query 'count_unique', {
        eventCollection: 'checkbox',
        filters: [{
          operator: 'eq',
          property_name: 'check',
          property_value: true
        }],
        targetProperty: 'user',
        groupBy: 'step_title',
        timeframe: 'this_14_days',
        timezone: 'US/Pacific'
      }
      $rootScope.keenio.draw top_steps, document.getElementById('top_steps'), {
        chartType: 'table'
        chartOptions: tableOptions
      }

  return
