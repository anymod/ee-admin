'use strict'

angular.module('app.core').controller 'usersCtrl', (eeUsers) ->

  users = this
  users.data = eeUsers.data
  # users.data.inputs.order = 'updated_at_desc'

  users.fns = eeUsers.fns

  eeUsers.fns.search()

  users.mailto =
    subject: "Welcome to eeosk"
    body: "Hello and welcome to eeosk. We're happy you joined!\n\nI am checking in and see how things are going with getting your store started on eeosk and if you would like any help. I'm available to speak with you over the phone to walk you through the store building and selling process or to provide any technical or marketing support. Just let me know if you are interested and we can find a time to connect on the phone or I can answer any questions over email.\n\neeosk is always looking for feedback so if there's something you'd like to see please let us know so we can create it for you. We continue to expand our product catalog so check back often!\n\nThanks again and don't hesitate to reach out with any questions.\n\nCheers,\nTyler & the eeosk team\nhttps://eeosk.com"

  return
