cloudinary = require './setup'

## Methods
# http://cloudinary.com/documentation/admin_api

delete_all_uploads = (kill) ->
  console.log 'starting delete'
  cloudinary.api.delete_all_resources (result) ->
    console.log 'cloudinary delete_all_derivatives', result
    if kill is true then process.exit()
  , { type: 'upload', keep_original: false }

delete_all_additional_images = (kill) ->
  console.log 'starting delete'
  cloudinary.api.delete_all_resources (result) ->
    console.log 'cloudinary delete_all_additional_images', result
    if kill is true then process.exit()
  , { type: 'upload', tag: 'additional_image', keep_original: false }

delete_all_derivatives = (kill) ->
  cloudinary.api.delete_all_resources (result) ->
    console.log 'cloudinary delete_all_derivatives', result
    if kill is true then process.exit()
  , { type: 'upload', keep_original: true }

delete_all_by_tag = (tag, kill) ->
  if !tag then return
  cloudinary.api.delete_resources_by_tag tag, (result) ->
    console.log 'cloudinary delete_all_by_tag', tag, result
    if kill is true then process.exit()

## Options

# NODE_ENV='test' DELETE_ALL_DERIVATIVES='true' coffee config/cloudinary/cloudinary.utils.coffee
if process.env.DELETE_ALL_DERIVATIVES is 'true' then delete_all_derivatives(true)
if process.env.DELETE_ALL_ADDITIONAL_IMAGES is 'true' then delete_all_additional_images(true)

# DELETE_ALL_BY_TAG='true' TAG='foobar' coffee config/cloudinary/cloudinary.utils.coffee
if process.env.DELETE_ALL_BY_TAG is 'true' then delete_all_by_tag(process.env.TAG)

# DELETE_ALL_UPLOADS='true' coffee config/cloudinary/cloudinary.utils.coffee
# if process.env.DELETE_ALL_UPLOADS is 'true' then delete_all_uploads(true)
