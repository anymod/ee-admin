angular.module 'ee-admin-live-button', []

angular.module('ee-admin-live-button').directive "eeAdminLiveButton", ($state, $stateParams) ->
  templateUrl: 'components/ee-admin-live-button.html'
  restrict: 'E'
  scope:
    user:     '='
    message:  '@'
    hiddenXs: '@'
    btnClass: '@'
  link: (scope, ele, attrs) ->
    scope.btnText = if scope.message then scope.message else 'View store'
    scope.root    = if scope.user?.domain then 'http://' + scope.user.domain else 'https://' + scope.user?.username + '.eeosk.com'
    scope.path    = '/'

    setButton = (toState, toParams) ->
      switch toState.name
        when 'products'
          scope.path += 'search'
        when 'productAdd'
          scope.path += 'products/' + toParams.id + '/'
          scope.btnText = 'See in store'
        when 'collection'
          scope.path += 'collections/' + toParams.id + '/'
          if scope.btnText is 'View store' then scope.btnText = 'See in store'
        else ''

      scope.target = scope.root + scope.path
      if scope.message is 'target' then scope.btnText = scope.target

    setButton $state.current, $stateParams

    scope.$on '$stateChangeStart', (event, toState, toParams) ->
      setButton toState, toParams

    return
