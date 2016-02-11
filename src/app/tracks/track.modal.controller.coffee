'use strict'

angular.module('tracks').controller 'trackModalCtrl', ($timeout, eeDefiner, eeModal, eeTrack, eeLane, eeActivity, data) ->

  modal = this

  modal.ee = eeDefiner.exports
  modal.data = data
  modal.editor = null

  modal.process = () ->
    switch modal.data.type
      when 'Update track', 'Reorder lanes' then eeTrack.fns.update(modal.data.track).then () -> eeModal.fns.close 'track'
      when 'Update lane', 'Reorder activities' then eeLane.fns.update(modal.data.lane).then () -> eeModal.fns.close 'track'
      when 'Update activity' then eeActivity.fns.update(modal.data.activity).then () -> eeModal.fns.close 'track'
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

  modal.reorder = (arr, index, moveBy) ->
    from  = index
    to    = index + moveBy
    arr.splice(to, 0, arr.splice(from, 1)[0])

  modal.summernoteConfig =
    height: 300
    focus: true
    toolbar: [
      ['style', ['style', 'bold', 'italic', 'height', 'clear']] # , 'underline', 'superscript', 'subscript', 'strikethrough'
      # ['fontface', ['fontname']]
      # ['textsize', ['fontsize']]
      # ['fontclr', ['color']]
      ['insert', ['link','video']] # ,'hr','picture'
      ['alignment', ['paragraph']] # , 'lineheight', 'ul', 'ol',
      ['height', ['table']]
      # ['help', ['help']]
      ['edit',['undo','redo']]
      ['view', ['codeview']] # 'fullscreen',
    ]

  $.cloudinary.config({ cloud_name: 'eeosk' })
  fn = () ->

    form = angular.element(document.querySelector('#cloudinaryForm'))
    cloudinary_transform = 'playbook'

    form
      .append($.cloudinary.unsigned_upload_tag cloudinary_transform, {
          cloud_name: 'eeosk',
          tags: 'playbook'
        }).bind('cloudinarydone', () -> console.log 'finished')

    assignAttr = (data) ->
      console.log 'assignAttr', data.result.secure_url

    resetProgress = () ->
      modal.progress = 0
      modal.partialProgress = 5

    imageDone = (e, data) ->
      console.log 'cloudinarydone'
      # resetProgress()
      # unbindCloudinary()
      # assignAttr(data)
      # # modal.$apply()
      # # $rootScope.$broadcast 'cloudinaryUploadFinished'
      # bindCloudinary()

    imageProgress = (e, data) ->
      console.log 'cloudinaryprogress'
      percentage = Math.round((data.loaded * 100.0) / data.total)
      # Only modal.$apply periodically
      if percentage > modal.partialProgress
        modal.partialProgress = percentage + 5
        modal.progress = if modal.progress > 99 then 0 else percentage
        # modal.$apply()

    # bindCloudinary = () ->
    #   console.log 'bindCloudinary'
    #   # form.on 'cloudinarydone', () -> imageDone()
    #   form
    #     .on 'cloudinaryprogress', imageProgress

      unbindCloudinary = () ->
        form.unbind 'cloudinaryprogress'
        form.unbind 'cloudinarydone'

    resetProgress()
    # bindCloudinary()

    # modal.progress = 0
    # modal.partialProgress = 5
    # form = angular.element(document.querySelector('#cloudinaryForm'))
    # form
    #   .append($.cloudinary.unsigned_upload_tag 'playbook', {
    #       cloud_name: 'eeosk',
    #       tags: 'playbook'
    #     })
    # form
    #   .bind 'cloudinarydone', (e, data) ->
    #     console.log 'done!', data
    #     addImage data.result.secure_url
    #     # resetProgress()
    #     # unbindCloudinary()
    #     form.unbind 'cloudinaryprogress'
    #     form.unbind 'cloudinarydone'
    #     # assignAttr(data)
    #     # scope.$apply()
    #     # $rootScope.$broadcast 'cloudinaryUploadFinished'
    #     # bindCloudinary()
    #   .bind 'cloudinaryprogress', (e, data) ->
    #     percentage = Math.round((data.loaded * 100.0) / data.total)
    #     # Only scope.$apply periodically
    #     console.log modal.partialProgress
    #     if percentage > modal.partialProgress
    #       modal.partialProgress = percentage + 5
    #       modal.progress = if modal.progress > 99 then 0 else percentage
    #       console.log modal.partialProgress
    #       # scope.$apply()

  $timeout fn, 500

  addImage = (url) ->
    imgNode = $('<img>').attr('src', url)[0]
    modal.editor.summernote('insertNode', imgNode)

  return
