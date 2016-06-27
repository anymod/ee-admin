'use strict'

angular.module('app.core').controller 'customersCtrl', ($rootScope) ->

  customers = this

  ##

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
    height: '250px'

  Keen.ready () ->

    # SR signups

    srSignups = new Keen.Query 'count', {
      eventCollection: 'signup',
      filters: [
        {
          operator: 'contains',
          property_name: 'url',
          property_value: 'stylishrustic.com'
        },{
          operator: 'exists'
          property_name: 'host',
          property_value: true
        }
      ],
      interval: 'daily'
      timeframe: 'this_14_days',
      timezone: 'US/Pacific'
    }
    $rootScope.keenio.draw srSignups, document.getElementById('sr-signups'), { chartOptions: chartOptions }

    srSignupsByReferer = new Keen.Query 'count', {
      eventCollection: 'signup',
      filters: [
        {
          operator: 'contains',
          property_name: 'url',
          property_value: 'stylishrustic.com'
        },{
          operator: 'exists'
          property_name: 'referer',
          property_value: true
        }
      ],
      groupBy: 'refererDomain',
      interval: 'daily',
      timeframe: 'this_14_days',
      timezone: 'US/Pacific'
    }
    $rootScope.keenio.draw srSignupsByReferer, document.getElementById('sr-signups-by-referer'), {
      chartType: 'columnchart'
      chartOptions: chartOptions
    }

    srSignupsByText = new Keen.Query 'count', {
      eventCollection: 'signup',
      filters: [
        {
          operator: 'contains',
          property_name: 'url',
          property_value: 'stylishrustic.com'
        },{
          operator: 'exists'
          property_name: 'signupText',
          property_value: true
        }
      ],
      groupBy: 'signupText',
      timeframe: 'this_14_days',
      timezone: 'US/Pacific'
    }
    $rootScope.keenio.draw srSignupsByText, document.getElementById('sr-signups-by-text'), {
      chartType: 'table',
      chartOptions: tableOptions
    }

    srSignupsByIdentifier = new Keen.Query 'count', {
      eventCollection: 'signup',
      filters: [
        {
          operator: 'contains',
          property_name: 'url',
          property_value: 'stylishrustic.com'
        },{
          operator: 'exists'
          property_name: 'signupIdentifier',
          property_value: true
        }
      ],
      groupBy: 'signupIdentifier',
      interval: 'daily',
      timeframe: 'this_14_days',
      timezone: 'US/Pacific'
    }
    $rootScope.keenio.draw srSignupsByIdentifier, document.getElementById('sr-signups-by-identifier'), {
      chartType: 'columnchart'
      chartOptions: chartOptions
    }

    srSignupsByPath = new Keen.Query 'count', {
      eventCollection: 'signup',
      filters: [
        {
          operator: 'contains',
          property_name: 'url',
          property_value: 'stylishrustic.com'
        },{
          operator: 'exists'
          property_name: 'path',
          property_value: true
        }
      ],
      groupBy: 'path',
      timeframe: 'this_14_days',
      timezone: 'US/Pacific'
    }
    $rootScope.keenio.draw srSignupsByPath, document.getElementById('sr-signups-by-path'), {
      chartType: 'table',
      chartOptions: tableOptions
    }

    srSignupsByPageDepth = new Keen.Query 'count', {
      eventCollection: 'signup',
      filters: [
        {
          operator: 'contains',
          property_name: 'url',
          property_value: 'stylishrustic.com'
        },{
          operator: 'exists'
          property_name: 'pageDepth',
          property_value: true
        }
      ],
      groupBy: 'pageDepth',
      timeframe: 'this_14_days',
      timezone: 'US/Pacific'
    }
    $rootScope.keenio.draw srSignupsByPageDepth, document.getElementById('sr-signups-by-page-depth'), {
      chartType: 'table',
      chartOptions: tableOptions
    }

  return
