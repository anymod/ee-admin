'use strict'

angular.module('tracks').controller 'trackModalCtrl', (eeDefiner, eeModal, eeTrack, eeLane, eeActivity, data) ->

  modal = this

  modal.ee = eeDefiner.exports
  modal.data = data

  modal.process = () ->
    switch modal.data.type
      when 'Update track'     then eeTrack.fns.update(modal.data.track).then () -> eeModal.fns.close 'track'
      when 'Update lane'      then eeLane.fns.update(modal.data.lane).then () -> eeModal.fns.close 'track'
      when 'Update activity'  then eeActivity.fns.update(modal.data.activity).then () -> eeModal.fns.close 'track'
      when 'Create lane'
        eeLane.fns.create modal.data.lane
        .then (lane) ->
          modal.data.track.lanes.push lane.id
          eeTrack.fns.update modal.data.track
        .then () -> eeModal.fns.close 'track'
      when 'Create activity'
        eeActivity.fns.create modal.data.activity
        .then (activity) ->
          modal.data.lane.activities.push activity.id
          eeLane.fns.update modal.data.lane
        .then () ->
          eeModal.fns.close 'track'

  # this.setMainImage = (img) -> that.mainImage = img
  # this.save = (product) ->
  #   product.saving = true
  #   eeBack.fns.productPUT { id: product.id, title: product.title, content: product.content }, eeAuth.fns.getToken()
  #   .then (prod) ->
  #     eeProducts.fns.updateProduct prod
  #     eeModal.fns.close 'product'
  #   .catch (err) -> console.error err
  #   .finally () ->  product.saving = false

  return
