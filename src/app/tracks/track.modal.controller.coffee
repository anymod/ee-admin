'use strict'

angular.module('tracks').controller 'trackModalCtrl', ($scope, $timeout, eeDefiner, eeModal, eeTrack, eeLane, eeActivity, data) ->

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
        .finally () -> eeModal.fns.close 'track'
      when 'Create activity'
        modal.data.activity.track_id = modal.data.track.id
        eeActivity.fns.create modal.data.activity
        .then (activity) ->
          promiseObj = null
          if modal.data?.lane?.id
            promiseObj = () ->
              modal.data.lane.activities.push activity.id
              eeLane.fns.update modal.data.lane
          else
            promiseObj = () ->
              eeTrack.fns.get modal.data.track.id
              .then (tr) -> modal.data.track.unassigned_activities = tr.unassigned_activities
          promiseObj()
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
      ['view', ['fullscreen', 'codeview']]
    ]

  addImageToSummernote = (url) ->
    imgNode = $('<img>').attr('src', url).attr('class','max-width-100-pct')[0]
    modal.editor.summernote('insertNode', imgNode)

  fn = () ->

    noteBtn = '<button id="insertImageBtn" type="button" class="btn btn-sm btn-default" title="Insert an image" tabindex="-1"><i class="fa fa-image"></i></button>'
    $(noteBtn).appendTo($('.note-toolbar .note-insert'))
    $('#insertImageBtn').on 'click', () -> $('#cloudinaryForm > .cloudinary_fileupload').click()

    form = angular.element(document.querySelector('#cloudinaryForm'))

    $.cloudinary.unsigned_upload_tag('playbook', {
      cloud_name: 'eeosk',
      tags: 'playbook'
    }).appendTo(form).bind('cloudinarydone', (e, data) ->
      resetProgress()
      addImageToSummernote data.result.secure_url
    ).bind('cloudinaryprogress', (e, data) ->
      percentage = Math.round((data.loaded * 100.0) / data.total)
      # Only modal.$apply periodically
      if percentage > modal.partialProgress
        modal.partialProgress = percentage + 5
        modal.progress = if modal.progress > 99 then 0 else percentage
        $scope.$apply()
    )

    resetProgress = () ->
      modal.progress = 0
      modal.partialProgress = 5

    resetProgress()


  if modal.data.type.indexOf('activity') > -1
    $timeout fn, 500



  return
