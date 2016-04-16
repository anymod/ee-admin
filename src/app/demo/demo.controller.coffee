'use strict'

angular.module('app.core').controller 'demoCtrl', () ->

  demo = this

  demo.meta =
    name: 'Example'
    brand:
      color:
        primary: '#555'
        tertiary: '#FFF'
    about: headline: '1'
    blog: url: '1'
    audience:
      social: { facebook: '1', twitter: '1', pinterest: '1', instagram: '1' }

  return
