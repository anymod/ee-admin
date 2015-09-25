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
  'taxonomies'
  'leads'
  'demo'
  'admin.auth'

  # custom
  'ee-navbar-main'
  'ee-storefront-header'
  'ee-product-admin'
  'ee-loading'
  # 'ee.templates' # commented out during build step for inline templates
]
