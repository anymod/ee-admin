cloudinary  = require '../config/cloudinary/setup'
Promise     = require 'bluebird'
_           = require 'lodash'

fns = {}

mockCloudinaryResponse = () ->
  random_image = fns.randomImage()
  {
    public_id: 'w5so0r7jtphkj6jf7usx'
    version: fns.randomInteger(9)
    signature: 'de3ae13a11b74c04747f3e88cc6de202886b6876'
    width: random_image.width
    height: random_image.height
    format: 'jpg'
    resource_type: 'image'
    created_at: '2015-01-28T00:21:47Z'
    bytes: 38540
    type: 'upload'
    url: random_image.url + '?mock_cloudinary_' + Date.now()
    secure_url: random_image.url + '?mock_cloudinary_' + Date.now()
    etag: 'a0c8141c262536fe442d9b5dcbc2ec11'
  }

fns.cloudinaryUploadAsync = (url, options) ->
  new Promise (resolve, reject) ->
    if process.env.NODE_ENV is 'test'
      resolve mockCloudinaryResponse()
    else
      cloudinary.uploader.upload url, ((result) -> resolve(result)), options

module.exports = fns
