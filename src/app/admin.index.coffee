'use strict'

angular.module 'eeAdmin', [
  # vendor
  'ui.router'
  'ui.bootstrap'
  'ngCookies'

  # core
  'app.core'

  # admin
  'users'
  'products'
  'leads'
  'demo'
  'admin.auth'

  # custom
  'ee-navbar-main'
  'ee-storefront-header'
  # 'ee.templates' # commented out during build step for inline templates
]
