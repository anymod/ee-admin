'use strict'

module = angular.module 'ee-datepicker', []

angular.module('ee-datepicker').directive "eeDatepicker", () ->
  templateUrl: 'components/ee-datepicker.html'
  restrict: 'EA'
  scope:
    user: '='
    year: '='
    month: '='
    day: '='
  link: (scope, ele, attrs) ->
    scope.dayWidth = 34
    calendarMonths = [ 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December' ]

    d = new Date()
    scope.month = calendarMonths[d.getMonth()]
    scope.day = d.getDate()
    scope.year = d.getFullYear()

    scope.visibleMonths = [ 'January', 'December', 'November' ]
    scope.visibleDays   = [scope.day..1]

    # scope.setViewTo = (view, value) ->
    #   user.monthViewActive = view is 'month'
    #   user.dayViewActive = !user.monthViewActive
    #   if user.months.indexOf(value) > -1
    #     user.currentDay = null
    #     user.currentMonth = value
    #   if user.days.indexOf(value) > -1 then user.currentDay = value

    return
