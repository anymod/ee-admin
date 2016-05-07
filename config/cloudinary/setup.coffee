cloudinary = require 'cloudinary'

if process.env.NODE_ENV is 'production'
  cloudinary.config
    cloud_name: 'eeosk'
    api_key: '895735444835457'
    api_secret: 'Bf7G8xPaSyYsqwTCK0Hbxc_PtlM'
else
  cloudinary.config
    cloud_name: 'eeosk-team'
    api_key: '975364837487286'
    api_secret: 'L5-vVa218yF5fwLWYJ6oPpaB0S0'

module.exports = cloudinary
