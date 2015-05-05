'use strict'

angular.module('app.core').controller 'productModalCtrl', ($rootScope, product, eeBack, eeAuth, eeDefiner, eeCatalog, eeModal) ->

  that            = this
  this.ee         = eeDefiner.exports
  this.product    = product
  this.mainImage  = this.product?.image_meta?.main_image

  this.setMainImage = (img) -> that.mainImage = img
  this.save = (product) ->
    product.saving = true
    eeBack.productPUT { id: product.id, title: product.title, content: product.content }, eeAuth.fns.getToken()
    .then (prod) ->
      eeCatalog.fns.updateProduct prod     
      eeModal.fns.close 'product'
    .catch (err) -> console.error err
    .finally () ->  product.saving = false

  return
