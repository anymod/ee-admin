spawn = require('child_process').spawn

argv  = require('yargs').argv
gulp  = require 'gulp'
gp    = do require "gulp-load-plugins"

streamqueue = require 'streamqueue'
combine     = require 'stream-combiner'
protractor  = require('gulp-protractor').protractor

sources     = require './gulp.sources'

# ==========================
# task options

distPath = './dist'

htmlminOptions =
  removeComments: true
  removeCommentsFromCDATA: true
  collapseWhitespace: true
  # conservativeCollapse: true # otherwise <i> & text squished
  collapseBooleanAttributes: true
  removeAttributeQuotes: true
  removeRedundantAttributes: true
  caseSensitive: true
  minifyJS: true
  minifyCSS: true

## ==========================
## html tasks

gulp.task 'html-dev', () ->
  gulp.src './src/index.html'
    .pipe gp.plumber()
    .pipe gp.htmlReplace
      css: 'stylesheets/ee.admin.css'
      js: sources.adminJs(), { keepBlockTags: true }
    .pipe gulp.dest './src'

gulp.task 'html-prod', () ->
  gulp.src './src/index.html'
    .pipe gp.plumber()
    # TODO Replace localhost tracking code with production tracking code
    # .pipe gp.replace /UA-55625421-2/g, 'UA-55625421-1'
    .pipe gp.htmlReplace
      css: 'ee.admin.css'
      js: 'ee.admin.js'
    .pipe gp.htmlmin htmlminOptions
    .pipe gulp.dest distPath

# ==========================
# css tasks

gulp.task 'css-dev', () ->
  gulp.src './src/stylesheets/ee.admin.less' # ** force to same dir
    .pipe gp.sourcemaps.init()
    .pipe gp.less paths: './src/stylesheets/' # @import path
    # write sourcemap to separate file w/o source content to path relative to dest below
    .pipe gp.sourcemaps.write './', { includeContent: false, sourceRoot: '../' }
    .pipe gulp.dest './src/stylesheets'

gulp.task 'css-prod', () ->
  gulp.src './src/stylesheets/ee.admin.less'
    # TODO: wait for minifyCss to support sourcemaps
    .pipe gp.replace "../bower_components/bootstrap/fonts/", "./fonts/"
    .pipe gp.replace "../bower_components/font-awesome/fonts/", "./fonts/"
    .pipe gp.less paths: './src/stylesheets/' # @import path
    .pipe gp.minifyCss cache: true, keepSpecialComments: 0 # remove all
    .pipe gulp.dest distPath

# ==========================
# js tasks

gulp.task 'js-test', () ->
  gulp.src './src/**/*.coffee' # ** glob forces dest to same subdir
    .pipe gp.replace /@@eeBackUrl/g, 'http://localhost:5555'
    .pipe gp.replace /@@eeTidyUrl/g, 'http://localhost:7777'
    .pipe gp.replace /@@eeAdminUrl/g, 'http://localhost:9999'
    .pipe gp.plumber()
    .pipe gp.sourcemaps.init()
    .pipe gp.coffee()
    .pipe gp.sourcemaps.write './'
    .pipe gulp.dest './src/js'

gulp.task 'js-dev', () ->
  gulp.src './src/**/*.coffee' # ** glob forces dest to same subdir
    .pipe gp.replace /@@eeBackUrl/g, 'http://localhost:5000'
    .pipe gp.replace /@@eeTidyUrl/g, 'http://localhost:7000'
    .pipe gp.replace /@@eeAdminUrl/g, 'http://localhost:9000'
    .pipe gp.plumber()
    .pipe gp.sourcemaps.init()
    .pipe gp.coffee()
    .pipe gp.sourcemaps.write './'
    .pipe gulp.dest './src/js'

gulp.task 'js-prod', () ->
  # inline templates; no need for ngAnnotate
  appTemplates = gulp.src './src/components/ee*.html'
    .pipe gp.htmlmin htmlminOptions
    .pipe gp.angularTemplatecache
      module: 'ee.templates'
      standalone: true
      root: 'components'

  adminVendorMin    = gulp.src(sources.adminVendorMin)
  adminVendorUnmin  = gulp.src(sources.adminVendorUnmin)
  # builder modules; replace and annotate
  adminModules = gulp.src sources.adminModules()
    .pipe gp.plumber()
    .pipe gp.replace "# 'ee.templates'", "'ee.templates'" # for builder.index.coffee $templateCache
    .pipe gp.replace "'env', 'development'", "'env', 'production'" # TODO use gulp-ng-constant
    .pipe gp.replace /@@eeBackUrl/g, 'https://api.eeosk.com'
    .pipe gp.replace /@@eeTidyUrl/g, 'https://ee-tidy.herokuapp.com'
    .pipe gp.replace /@@eeAdminUrl/g, 'https://ee-admin.herokuapp.com'
    .pipe gp.coffee()
    .pipe gp.ngAnnotate()
  # minified and uglify vendorUnmin, templates, and modules
  adminCustomMin = streamqueue objectMode: true, adminVendorUnmin, appTemplates, adminModules
    .pipe gp.uglify()
  # concat: vendorMin before jsMin because vendorMin has angular
  streamqueue objectMode: true, adminVendorMin, adminCustomMin
    .pipe gp.concat 'ee.admin.js'
    .pipe gulp.dest distPath

# ==========================
# other tasks
# copy non-compiled files

gulp.task "copy-prod", () ->
  sameDirFiles = [

  ]
  gulp.src ['./src/img/**/*.*', './src/app/**/*.html'], base: './src'
    .pipe gp.plumber()
    .pipe gp.changed distPath
    .pipe gulp.dest distPath

  gulp.src './src/bower_components/bootstrap/fonts/**/*.*'
    .pipe gp.plumber()
    .pipe gp.changed distPath
    .pipe gulp.dest distPath + '/fonts'

  gulp.src './src/bower_components/font-awesome/fonts/**/*.*'
    .pipe gp.plumber()
    .pipe gp.changed distPath
    .pipe gulp.dest distPath + '/fonts'


# ==========================
# protractors

gulp.task 'protractor-test', () ->
  gulp.src ['./src/e2e/config.coffee', './src/e2e/*.coffee']
    .pipe protractor
      configFile: './protractor.conf.js'
      args: ['--grep', (argv.grep || ''), '--baseUrl', 'http://localhost:3333', '--apiUrl', 'http://localhost:5555']
    .on 'error', (e) -> return

gulp.task 'protractor-prod', () ->
  gulp.src ['./src/e2e/config.coffee', './src/e2e/*.coffee']
    .pipe protractor
      configFile: './protractor.conf.js'
      args: ['--baseUrl', 'http://localhost:3333', '--apiUrl', 'http://localhost:5555']
    .on 'error', (e) -> return

gulp.task 'protractor-live', () ->
  gulp.src ['./src/e2e/config.coffee', './src/e2e/*.coffee']
    .pipe protractor
      configFile: './protractor.conf.js'
      args: ['--grep', (argv.grep || ''), '--baseUrl', 'https://eeosk.com', '--apiUrl', 'https://api.eeosk.com']
    .on 'error', (e) -> return

# ==========================
# servers

gulp.task 'server-test', () ->
  gulp.src('./src').pipe gp.webserver(
    fallback: 'index.html' # for angular html5mode
    port: 9999
  )

gulp.task 'server-dev', () ->
  gulp.src('./src').pipe gp.webserver(
    fallback: 'index.html' # for angular html5mode
    port: 9000
  )

gulp.task 'server-prod', () -> spawn 'foreman', ['start'], { stdio: 'inherit' }

# ==========================
# watchers

gulp.task 'watch-dev', () ->
  gulp.src './src/stylesheets/ee*.less'
    .pipe gp.watch { emit: 'one', name: 'css' }, ['css-dev']
  gulp.src './src/**/*.coffee'
    .pipe gp.watch { emit: 'one', name: 'js' }, ['js-dev']
  gulp.src './src/**/*.html'
    .pipe gp.watch { emit: 'one', name: 'html' }, ['html-dev']

gulp.task 'watch-test', () ->
  gulp.src './src/stylesheets/ee*.less'
    .pipe gp.watch { emit: 'one', name: 'css' }, ['css-dev']
  gulp.src './src/**/*.coffee'
    .pipe gp.watch { emit: 'one', name: 'js' }, ['js-test']
  gulp.src './src/e2e/*e2e*.coffee'
    .pipe gp.watch { emit: 'one', name: 'test' }, ['protractor-test']

# ===========================
# runners

gulp.task 'test', ['js-test', 'html-dev', 'server-test', 'watch-test'], () -> return

gulp.task 'dev', ['watch-dev', 'server-dev'], () -> return

gulp.task 'prod-test', ['pre-prod-test', 'protractor-prod']

gulp.task 'prod', ['css-prod', 'js-prod', 'html-prod', 'copy-prod', 'server-prod'], () -> return
