angular.module 'ee-user-admin', []

angular.module('ee-user-admin').directive "eeUserAdmin", ($rootScope, $window, eeAuth, eeBack) ->
  templateUrl: 'components/ee-user-admin.html'
  restrict: 'E'
  scope:
    user:         '='
    showOnboard:  '@'
    showActivity: '@'
    subject:      '='
    body:         '='
  link: (scope, ele, attrs) ->
    scope.user.reading = false
    scope.mailto = null

    if scope.showActivity is 'true' and scope.user?.tr_uuid
      Keen.ready () ->

        query = new Keen.Query 'count', {
          eventCollection: 'builder',
          filters: [{
            operator: 'eq',
            property_name: 'user',
            property_value: scope.user.tr_uuid
          }],
          groupBy:    'toState',
          interval:   'daily',
          timeframe:  'this_7_days',
          timezone:   'US/Pacific'
        }
        chart_ele = ele[0].querySelector('.chart')
        $rootScope.keenio.draw query, chart_ele, { chartType: 'columnchart' }

    if scope.showOnboard
      scope.onboard = () ->
        scope.user.reading = true
        if scope.mailto
          $window.open scope.mailto, '_blank'
        else
          eeBack.fns.userEmailGET scope.user.id, eeAuth.fns.getToken()
          .then (res) ->
            scope.mailto = 'mailto:' + res.email + '?Subject=' + encodeURI(scope.subject) + '&body=' + encodeURI(scope.body).replace(/\&/g, '%26')
            $window.open scope.mailto, '_blank'
          .catch (err) -> console.error err
          .finally () -> scope.user.reading = false

    return
