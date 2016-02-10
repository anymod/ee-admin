'use strict'

angular.module('app.core').factory 'eeModal', ($uibModal) ->

  ## SETUP
  _modals         = {}
  _backdropClass  = 'white-background opacity-08'

  _config =
    # login:
    #   templateUrl:    'builder/auth.login/auth.login.modal.html'
    #   controller:     'loginCtrl as modal'
    #   size:           'sm'
    #   backdropClass:  _backdropClass
    track:
      templateUrl:    'app/tracks/track.modal.html'
      controller:     'trackModalCtrl as modal'
      # size:           'sm'
      backdropClass:  _backdropClass


  ## PRIVATE FUNCTIONS
  _open = (name, data) ->
    if !name or !_config[name] then return
    modalObj = _config[name]
    modalObj.resolve = data: () -> data
    _modals[name] = $uibModal.open modalObj
    return

  _close = (name) ->
    if !_modals[name] then return
    _modals[name].close()
    return

  ## EXPORTS
  fns:
    open: _open
    close: _close

    openProductModal: (product) ->
      _modals.product = $uibModal.open({
        templateUrl: 'app/products/product.modal.html'
        backdropClass: 'white-background opacity-08'
        resolve:
          product: () -> product
        controller: 'productModalCtrl as modal'
      })

    closeLoginModal:        () -> _close 'login'
