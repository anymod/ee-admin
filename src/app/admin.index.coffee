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
  'ee-storefront-logo'
  'ee-storefront-header'
  'ee-user-for-admin'
  'ee-product-for-admin'
  'ee-sku-for-admin'
  'ee-admin-user'
  'ee-admin-live-button'
  'ee-admin-user-navbar'
  'ee-loading'
  'ee-datepicker'
  # 'ee.templates' # commented out during build step for inline templates
]
