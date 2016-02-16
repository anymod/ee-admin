angular.module 'ee-navbar-main', []

angular.module('ee-navbar-main').directive "eeNavbarMain", ($state, eeDefiner) ->
  templateUrl: 'components/ee-navbar-main.html'
  restrict: 'E'
  scope:
    usersNav: '@'
  link: (scope, ele, attrs) ->
    scope.ee    = eeDefiner.exports
    scope.state = $state.current.name
    return
