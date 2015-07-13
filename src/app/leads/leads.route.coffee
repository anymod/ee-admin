'use strict'

angular.module('leads').config ($stateProvider) ->

  views =
    header:
      controller: 'leadsCtrl as leads'
      templateUrl: 'app/leads/leads.header.html'
    top:
      controller: 'leadsCtrl as leads'
      templateUrl: 'app/leads/leads.html'

  data =
    pageTitle:        'Leads'
    padTop:           '100px'

  $stateProvider
    .state 'leads',
      url:      '/leads'
      views:    views
      data:     data

  return
