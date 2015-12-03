'use strict'

angular.module('app.core').controller 'activityCtrl', ($rootScope) ->

  activity = this

  Keen.ready () ->

    # DAILY ACTIVE SELLERS
    das = new Keen.Query 'count_unique', {
      eventCollection: 'builder',
      interval: 'daily'
      targetProperty: 'username',
      groupBy: 'username',
      timeframe: 'this_30_days',
      timezone: 'US/Pacific'
    }
    $rootScope.keenio.draw das, document.getElementById('das'), {
      title: 'Daily Active Sellers',
      chartType: 'columnchart',
      chartOptions:
        isStacked: true
        legend:
          position: 'none'
        titleTextStyle:
          fontSize: 16
          bold: false
    }

    # MOST ACTIVE SELLERS
    active_sellers = new Keen.Query 'count', {
      eventCollection: 'builder',
      groupBy: 'username',
      timeframe: 'this_14_days',
      timezone: 'US/Pacific'
    }
    $rootScope.keenio.draw active_sellers, document.getElementById('active_sellers'), {
      title: '14-day Visits',
      chartType: 'piechart',
      chartOptions:
        legend: position: 'none'
        chartArea: width: '100%'
        titleTextStyle:
          fontSize: 16
          bold: false
    }

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
      title: 'Daily Active Customers (by store)'
      chartType: 'columnchart'
      chartOptions:
        isStacked: true
        legend: position: 'none'
        titleTextStyle:
          fontSize: 16
          bold: false
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
    top_performers_cutoff = 1
    top_performers_chart = new Keen.Dataviz()
      .el(document.getElementById('top_performers'))
      .title '14-day Performers (n > ' + top_performers_cutoff + ')'
      .chartType 'piechart'
      .chartOptions {
        legend: position: 'none'
        chartArea: width: '100%'
        titleTextStyle:
          fontSize: 16
          bold: false
      }
      .prepare()
    $rootScope.keenio.run top_performers, (err, res) ->
      if err then return top_performers_chart.error(err.message)
      stores = []
      for store in res.result
        if store.result > top_performers_cutoff then stores.push store
      top_performers_chart.parseRawData({ result: stores }).render()

  return
