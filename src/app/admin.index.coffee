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
  'admin.auth'

  # custom
  'ee-navbar-main'
  # 'ee.templates' # commented out during build step for inline templates
]
