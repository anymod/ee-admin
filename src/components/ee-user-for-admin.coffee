angular.module 'ee-user-for-admin', []

angular.module('ee-user-for-admin').directive "eeUserForAdmin", ($rootScope, $state, $window, eeAuth, eeBack) ->
  templateUrl: 'components/ee-user-for-admin.html'
  restrict: 'EA'
  replace: true
  scope:
    user:   '='
    state:  '='
  link: (scope, ele, attrs) ->
    scope.user.reading = false
    scope.mailto = null
    scope.target = if scope.user?.domain then 'http://' + scope.user.domain else 'https://' + scope.user?.username + '.eeosk.com'

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
    setAnalytics = () -> $rootScope.keenio.draw query, chart_ele, { chartType: 'columnchart' }

    Keen.ready () ->
      $rootScope.$on '$stateChangeSuccess', (e, toState) ->
        if toState.name is 'users.analytics' then setAnalytics()
      if $state.current.name is 'users.analytics' then setAnalytics()

    scope.subject = "Welcome to eeosk"
    scope.body    = "Hello and welcome to eeosk. We're happy you joined!\n\nI am checking in and see how things are going with getting your store started on eeosk and if you would like any help. I'm available to speak with you over the phone to walk you through the store building and selling process or to provide any technical or marketing support. Just let me know if you are interested and we can find a time to connect on the phone or I can answer any questions over email.\n\neeosk is always looking for feedback so if there's something you'd like to see please let us know so we can create it for you. We continue to expand our product catalog so check back often!\n\nThanks again and don't hesitate to reach out with any questions.\n\nCheers,\nGreer & the eeosk team\nhttps://eeosk.com"

    return
