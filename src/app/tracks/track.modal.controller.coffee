'use strict'

angular.module('tracks').controller 'trackModalCtrl', (eeDefiner, eeModal, eeTrack, eeLane, eeActivity, data) ->

  modal = this

  modal.ee = eeDefiner.exports
  modal.data = data

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
      ['insert', ['link','picture','video']] # ,'hr'
      ['alignment', ['paragraph']] # , 'lineheight', 'ul', 'ol',
      ['height', ['table']]
      # ['help', ['help']]
      ['edit',['undo','redo']]
      ['view', ['codeview']] # 'fullscreen',
    ]

  return
