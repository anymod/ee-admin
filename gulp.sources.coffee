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
  './src/bower_components/angular/angular.min.js'
  './src/bower_components/angular-ui-router/release/angular-ui-router.min.js'
  './src/bower_components/angular-cookies/angular-cookies.min.js'
  './src/bower_components/angular-bootstrap/ui-bootstrap.min.js'
  './src/bower_components/angular-bootstrap/ui-bootstrap-tpls.min.js'
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
  './src/app/core/svc.catalog.coffee'
  './src/app/core/svc.leads.coffee'
  './src/app/core/svc.users.coffee'
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
  # Module - users
  './src/app/users/users.module.coffee'
  './src/app/users/users.route.coffee'
  './src/app/users/users.controller.coffee'
  # Module - products
  './src/app/products/products.module.coffee'
  './src/app/products/products.route.coffee'
  './src/app/products/products.controller.coffee'
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
  './src/components/ee-storefront-header.coffee'
]

module.exports = sources
