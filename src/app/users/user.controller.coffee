'use strict'

angular.module('app.core').controller 'userCtrl', ($rootScope, $stateParams, eeUser) ->

  user = this
  user.id = $stateParams.id

  months = [
    { name: 'January',    days: 31 }
    { name: 'February',   days: 28 }
    { name: 'March',      days: 31 }
    { name: 'April',      days: 30 }
    { name: 'May',        days: 31 }
    { name: 'June',       days: 30 }
    { name: 'July',       days: 31 }
    { name: 'August',     days: 31 }
    { name: 'September',  days: 30 }
    { name: 'October',    days: 31 }
    { name: 'November',   days: 30 }
    { name: 'December',   days: 31 }
  ]

  user.reading = true
  eeUser.fns.get user.id
  .then (res) ->
    user.user = res
    console.log res.created_at
    d = new Date()
    user.currentMonth = months[d.getMonth()].name
    user.currentDay = d.getDate()
    user.days = [user.currentDay..1]
    # createCharts user.user
  .finally () -> user.reading = false

  user.dayViewActive = true
  user.currentDay = null
  user.dayWidth = 34

  user.monthViewActive = false
  user.months = ['January', 'December', 'November']
  user.currentMonth = null

  user.setViewTo = (view, value) ->
    user.monthViewActive = view is 'month'
    user.dayViewActive = !user.monthViewActive
    if user.months.indexOf(value) > -1
      user.currentDay = null
      user.currentMonth = value
    if user.days.indexOf(value) > -1 then user.currentDay = value

  createCharts = (u) ->
    filters = [{
      operator: 'eq',
      property_name: 'user',
      property_value: u.tr_uuid
    },{
      operator: 'exists',
      property_name: 'refererDomain',
      property_value: true
    }]
    for prop in ['eeosk', 'localhost', 'herokuapp']
      filters.push {
        operator: 'not_contains',
        property_name: 'refererDomain',
        property_value: prop
      }
    for prop in ['username', 'domain']
      if user.user[prop] then filters.push {
        operator: 'not_contains',
        property_name: 'refererDomain',
        property_value: u[prop]
      }

    Keen.ready () ->

      storeCount = new Keen.Query 'count', {
        eventCollection: 'store'
        filters: filters
        groupBy: ['refererDomain']
        interval: 'daily',
        timeframe: 'this_7_days',
        timezone: 'US/Pacific'
      }

      $rootScope.keenio.draw storeCount, document.getElementById('stacked_chart'), {
        title: 'Visits: Last 7 days'
        chartType: 'columnchart'
        isStacked: true
        legend: position: 'none'
      }

      storePie = new Keen.Query 'count', {
        eventCollection: 'store'
        filters: filters
        groupBy: ['refererDomain']
        timeframe: 'this_14_days',
        timezone: 'US/Pacific'
      }

      $rootScope.keenio.draw storePie, document.getElementById('pie_chart'), {
        title: 'Visits: Last 14-days'
        chartType: 'piechart'
      }

  return
