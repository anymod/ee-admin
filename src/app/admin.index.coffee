'use strict'

angular.module 'eeAdmin', [
  # vendor
  'ui.router'
  'ui.bootstrap'
  'ngCookies'

  # core
  'app.core'

  # admin
  'activity'
  'users'
  'products'
  'taxonomies'
  'leads'
  'demo'
  'admin.auth'

  # custom
  'ee-navbar-main'
  'ee-storefront-header'
  'ee-storefront-logo'
  'ee-product-for-admin'
  'ee-sku-for-admin'
  'ee-user-admin'
  'ee-admin-live-button'
  'ee-admin-user-navbar'
  'ee-loading'
  # 'ee.templates' # commented out during build step for inline templates
]
