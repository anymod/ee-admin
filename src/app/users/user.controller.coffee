'use strict'

angular.module('app.core').controller 'userCtrl', ($rootScope, $stateParams, $scope, eeUser) ->

  user = this
  user.id = $stateParams.id

  user.calendarMonths = [ 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December' ]

  today = new Date()
  user.selectedYear   = today.getFullYear()
  user.selectedMonth  = today.getMonth()
  user.selectedDay    = today.getDate()

  user.reading = true
  eeUser.fns.get user.id
  .then (res) ->
    user.user = res
    createCharts user.user, user.selectedYear, user.selectedMonth, user.selectedDay
  .finally () -> user.reading = false

  keenioTimeframe = (endYear, endMonth, endDay, numDays) ->
    endDate = new Date(Date.parse('' + endYear + '-' + (endMonth + 1) + '-' + endDay))
    startDate = new Date(new Date(endDate).setDate(new Date(endDate).getDate() - numDays))
    suffix = 'T00:00:00.000-05:00'
    endTimeframe   = '' + [endDate.getFullYear(), ('0' + (endDate.getMonth() + 1)).substr(-2,2), ('0' + endDate.getDate()).substr(-2,2)].join('-') + suffix
    startTimeframe = '' + [startDate.getFullYear(), ('0' + (startDate.getMonth() + 1)).substr(-2,2), ('0' + startDate.getDate()).substr(-2,2)].join('-') + suffix
    [startTimeframe, endTimeframe]

  createCharts = (u, year, month, day) ->
    colorMapping =
      Facebook:   '#3b5998'
      Pinterest:  '#cc2127'
      Twitter:    '#55acee'
      Instagram:  '#3f729b'
      Google:     '#4285F4'

    baseFilters = [{
      operator: 'eq',
      property_name: 'user',
      property_value: u.tr_uuid
    }]
    tableFilters    = angular.copy baseFilters
    refererFilters  = angular.copy baseFilters

    for prop in ['eeosk', 'localhost', 'herokuapp']
      refererFilters.push {
        operator: 'not_contains',
        property_name: 'refererDomain',
        property_value: prop
      }
    for prop in ['username', 'domain']
      if user.user[prop] then refererFilters.push {
        operator: 'not_contains',
        property_name: 'refererDomain',
        property_value: u[prop]
      }

    tableTimeframe = keenioTimeframe year, month, day, 1
    refererTimeframe = keenioTimeframe year, month, day, 10

    # endDate = new Date(Date.parse('' + year + '-' + (month + 1) + '-' + day))
    # startDate = new Date(new Date(endDate).setDate(new Date(endDate).getDate() - 10))
    # suffix = 'T00:00:00.000-05:00'
    # endTimeframe   = '' + [endDate.getFullYear(), ('0' + (endDate.getMonth() + 1)).substr(-2,2), ('0' + endDate.getDate()).substr(-2,2)].join('-') + suffix
    # startTimeframe = '' + [startDate.getFullYear(), ('0' + (startDate.getMonth() + 1)).substr(-2,2), ('0' + startDate.getDate()).substr(-2,2)].join('-') + suffix

    Keen.ready () ->

      dailyTable = new Keen.Query 'count', {
        eventCollection: 'store'
        filters: baseFilters
        groupBy: ['path']
        timeframe:
          start: tableTimeframe[0]
          end: tableTimeframe[1]
        timezone: 'US/Eastern'
      }
      $rootScope.keenio.draw dailyTable, document.getElementById('visits_table'), {
        title: 'Visits'
        chartType: 'table'
        alternatingRowStyle: true
        sortColumn: 1
        sortAscending: false
      }

      storeCount = new Keen.Query 'count', {
        eventCollection: 'store'
        filters: refererFilters
        groupBy: ['refererDomain']
        interval: 'daily'
        timeframe:
          start: refererTimeframe[0]
          end: refererTimeframe[1]
        timezone: 'US/Eastern'
      }

      $rootScope.keenio.draw storeCount, document.getElementById('stacked_chart'), {
        title: 'Visits from other sites'
        chartType: 'columnchart'
        isStacked: true
        legend: position: 'none'
        height: 300
        chartArea:
          width: '100%'
          height: '70%'
        titlePosition: 'in'
        axisTitlesPosition: 'in'
        hAxis:
          direction: -1
          gridlines:
            color: 'transparent'
            count: 10
          # textPosition: 'in'
        vAxis:
          # gridlines: color: 'transparent'
          textPosition: 'in'
          maxValue: 4
        colorMapping: colorMapping
        # theme: 'maximized'
      }

      # storePie = new Keen.Query 'count', {
      #   eventCollection: 'store'
      #   filters: refererFilters
      #   groupBy: ['refererDomain']
      #   timeframe:
      #     start: refererTimeframe[0]
      #     end: refererTimeframe[1]
      #   timezone: 'US/Eastern'
      # }
      #
      # $rootScope.keenio.draw storePie, document.getElementById('pie_chart'), {
      #   title: 'Weekly visits'
      #   chartType: 'piechart'
      #   height: 300
      #   colorMapping: colorMapping
      # }

  $scope.$watchGroup ['user.selectedYear','user.selectedMonth','user.selectedDay'], (newValues, oldValues, scope) ->
    if user.user && user.selectedYear && user.selectedMonth isnt null && user.selectedDay
      console.log user.selectedYear, user.selectedMonth, user.selectedDay
      createCharts user.user, user.selectedYear, user.selectedMonth, user.selectedDay

  return
