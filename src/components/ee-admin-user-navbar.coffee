angular.module 'ee-admin-user-navbar', []

angular.module('ee-admin-user-navbar').directive "eeAdminUserNavbar", ($rootScope, $window, eeAuth, eeBack) ->
  templateUrl: 'components/ee-admin-user-navbar.html'
  restrict: 'E'
  scope:
    user: '='
  link: (scope, ele, attrs) ->
    scope.root = if scope.user?.domain then 'http://' + scope.user.domain else 'https://' + scope.user?.username + '.eeosk.com'
    return
