'use strict'

angular.module('admin.auth').controller 'loginCtrl', ($state, eeAuth) ->
  this.alert    = ''
  that          = this

  setBtnText    = (txt) -> that.btnText = txt
  resetBtnText  = ()    -> setBtnText 'Sign in'
  resetBtnText()

  # this.login = () ->
  #   that.alert = ''
  #   setBtnText 'Sending...'
  #   eeAuth.fns.setUserFromCredentials that.email, that.password
  #   .then () ->
  #     eeModal.fns.closeLoginModal()
  #     $state.go 'storefront'
  #   .catch (err) ->
  #     resetBtnText()
  #     alert = err.message || err || 'Problem logging in'
  #     if typeof alert is 'object' then alert = 'Problem logging in'
  #     that.alert = alert
  #
  # this.signup = () -> eeModal.fns.open 'signup'

  return
