'use strict'

angular.module('app.core').controller 'userCtrl', ($rootScope, $stateParams, eeUser) ->

  user = this
  user.id = $stateParams.id

  eeUser.fns.get user.id
  .then (res) ->
    user.user = res

    Keen.ready () ->

      query = new Keen.Query 'count', {
        eventCollection: 'store'
        filters: [{
          operator: 'eq',
          property_name: 'user',
          property_value: user.user.tr_uuid
        },{
          operator: 'not_contains',
          property_name: 'referer',
          property_value: 'eeosk.com'
        },{
          operator: 'not_contains',
          property_name: 'referer',
          property_value: 'localhost'
        },{
          operator: 'not_contains',
          property_name: 'referer',
          property_value: 'herokuapp'
        }]
        groupBy: ['referer']
        interval: 'daily',
        timeframe: 'this_14_days',
        timezone: 'UTC'
      }

      $rootScope.keenio.draw query, document.getElementById("my_chart"), { chartType: 'columnchart' }
          # Custom configuration here


  return
