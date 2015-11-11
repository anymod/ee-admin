'use strict'

angular.module('app.core').controller 'templateModalCtrl', ($rootScope, template, eeBack, eeAuth, eeDefiner, eeProducts, eeModal) ->

  that            = this
  this.ee         = eeDefiner.exports
  this.template   = template
  this.mainImage  = this.template?.image_meta?.main_image

  this.setMainImage = (img) -> that.mainImage = img
  this.save = (template) ->
    template.saving = true
    eeBack.templatePUT { id: template.id, title: template.title, content: template.content }, eeAuth.fns.getToken()
    .then (prod) ->
      eeProducts.fns.updateProduct prod
      eeModal.fns.close 'template'
    .catch (err) -> console.error err
    .finally () ->  template.saving = false

  return
