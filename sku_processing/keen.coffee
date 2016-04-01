Promise = require 'bluebird'
Keen    = require 'keen-js'

fns = {}

keenio = new Keen
  projectId: "565c9b27c2266c0bb36521db",
  readKey: "2e6b0efec92fef795b3f2f42cb77f8f9d9f07e6db31afdd27cf1b296657edeb9c7b3e4dccbe0019587d5b7e6b2221fb669114f7afa7813f081c3414df1a06b33bbd2fd26d71df0fa88f194dce9281c15b825dcd803fd61c824b8c45701cbe61c46e00cc4df1ca908f322b8f5ca60e856",
  writeKey: 'a36f4230d8a77258c853d2bcf59509edc5ae16b868a6dbd8d6515b9600086dbca7d5d674c9307314072520c35f462b79132c2a1654406bdf123aba2e8b1e880bd919482c04dd4ce9801b5865f4bc95d72fbe20769bc238e1e6e453ab244f9243cf47278e645b2a79398b86d7072cb75c'

fns.addSkuEvent = (payload) ->
  if process.env.NODE_ENV is 'production'
    new Promise (resolve, reject) ->
      keenio.addEvent 'skus', payload, (err, res) ->
        if err then return reject err
        resolve res
  else
    new Promise (resolve, reject) ->
      resolve { created: true }

module.exports = fns
