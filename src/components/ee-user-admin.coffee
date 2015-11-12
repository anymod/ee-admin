angular.module 'ee-user-admin', []

angular.module('ee-user-admin').directive "eeUserAdmin", ($window, eeAuth, eeBack) ->
  templateUrl: 'components/ee-user-admin.html'
  restrict: 'E'
  scope:
    user:     '='
    subject:  '='
    body:     '='
  link: (scope, ele, attrs) ->
    scope.user.reading = false
    scope.mailto = null

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
