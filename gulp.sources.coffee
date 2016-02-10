_       = require 'lodash'
sources = {}

stripSrc  = (arr) -> _.map arr, (str) -> str.replace('./src/', '')
toJs      = (arr) -> _.map arr, (str) -> str.replace('.coffee', '.js').replace('./src/', 'js/')
unmin     = (arr) ->
  _.map arr, (str) -> str.replace('dist/angulartics', 'src/angulartics').replace('.min.js', '.js')

sources.adminJs = () ->
  [].concat stripSrc(unmin(sources.adminVendorMin))
    .concat stripSrc(sources.adminVendorUnmin)
    .concat toJs(sources.appModule)
    .concat toJs(sources.adminModule)
    .concat toJs(sources.adminDirective)

sources.adminModules = () ->
  [].concat sources.appModule
    .concat sources.adminModule
    .concat sources.adminDirective

### VENDOR ###
sources.adminVendorMin = [
  './src/bower_components/jquery/dist/jquery.min.js' # for summernote
  './src/bower_components/angular/angular.min.js'
  './src/bower_components/angular-ui-router/release/angular-ui-router.min.js'
  './src/bower_components/angular-cookies/angular-cookies.min.js'
  './src/bower_components/angular-bootstrap/ui-bootstrap.min.js'
  './src/bower_components/angular-bootstrap/ui-bootstrap-tpls.min.js'
  './src/bower_components/angular-sanitize/angular-sanitize.min.js'
  './src/bower_components/keen-js/dist/keen.min.js'
  './src/bower_components/bootstrap/dist/js/bootstrap.min.js' # for summernote
  './src/bower_components/summernote/dist/summernote.min.js' # for summernote
  './src/bower_components/angular-summernote/dist/angular-summernote.min.js' # for summernote
]
sources.adminVendorUnmin = [

]

### MODULE ###
sources.appModule = [
  # Definitions
  './src/app/core/core.module.coffee'
  './src/app/core/constants.coffee'
  './src/app/core/filters.coffee'
  './src/app/core/config.coffee'
  './src/app/core/run.coffee'
  # Services
  './src/app/core/svc.back.coffee'
  './src/app/core/svc.auth.coffee'
  './src/app/core/svc.definer.coffee'
  './src/app/core/svc.modal.coffee'
  './src/app/core/svc.product.coffee'
  './src/app/core/svc.products.coffee'
  './src/app/core/svc.leads.coffee'
  './src/app/core/svc.user.coffee'
  './src/app/core/svc.users.coffee'
  './src/app/core/svc.taxonomies.coffee'
  './src/app/core/svc.categorizations.coffee'
  './src/app/core/svc.track.coffee'
  './src/app/core/svc.tracks.coffee'
  './src/app/core/svc.lane.coffee'
  './src/app/core/svc.activity.coffee'
  # Product modal
  './src/app/products/product.modal.controller.coffee'
]
sources.adminModule = [
  # Definitions
  './src/app/admin.index.coffee'
  # Services

  # Module - auth
  './src/app/auth/auth.module.coffee'
  # auth.login
  './src/app/auth.login/auth.login.route.coffee'
  './src/app/auth.login/auth.login.controller.coffee'
  # auth.logout
  './src/app/auth.logout/auth.logout.route.coffee'
  './src/app/auth.logout/auth.logout.controller.coffee'
  # Module - analytics
  './src/app/analytics/analytics.module.coffee'
  './src/app/analytics/analytics.route.coffee'
  './src/app/analytics/analytics.controller.coffee'
  # Module - tracks
  './src/app/tracks/tracks.module.coffee'
  './src/app/tracks/tracks.route.coffee'
  './src/app/tracks/tracks.controller.coffee'
  './src/app/tracks/track.controller.coffee'
  './src/app/tracks/track.modal.controller.coffee'
  # Module - users
  './src/app/users/users.module.coffee'
  './src/app/users/users.route.coffee'
  './src/app/users/users.controller.coffee'
  './src/app/users/user.controller.coffee'
  './src/app/users/user.dashboard.controller.coffee'
  # Module - products
  './src/app/products/products.module.coffee'
  './src/app/products/products.route.coffee'
  './src/app/products/products.controller.coffee'
  # Module - taxonomies
  './src/app/taxonomies/taxonomies.module.coffee'
  './src/app/taxonomies/taxonomies.route.coffee'
  './src/app/taxonomies/taxonomies.controller.coffee'
  # Module - leads
  './src/app/leads/leads.module.coffee'
  './src/app/leads/leads.route.coffee'
  './src/app/leads/leads.controller.coffee'
  # Module - demo
  './src/app/demo/demo.module.coffee'
  './src/app/demo/demo.route.coffee'
  './src/app/demo/demo.controller.coffee'
]

### DIRECTIVES ###
sources.adminDirective = [
  './src/components/ee-navbar-main.coffee'
  './src/components/ee-storefront-logo.coffee'
  './src/components/ee-storefront-header.coffee'
  './src/components/ee-user-for-admin.coffee'
  './src/components/ee-product-for-admin.coffee'
  './src/components/ee-sku-for-admin.coffee'
  './src/components/ee-admin-user.coffee'
  './src/components/ee-admin-live-button.coffee'
  './src/components/ee-admin-user-navbar.coffee'
  './src/components/ee-loading.coffee'
  './src/components/ee-datepicker.coffee'
]

module.exports = sources
