elasticsearch = require 'elasticsearch'
Promise       = require 'bluebird'

es = {}

host = if process.env.NODE_ENV is 'test' then 'https://user:pass@foobar.com' else 'https://vzsmdkyk:c8tmrwxnuz3ckum5@aralia-6944431.us-east-1.bonsai.io'

# https://www.elastic.co/guide/en/elasticsearch/client/javascript-api/current/configuration.html
es.client = new elasticsearch.Client({
    host: host,
    log: 'warning' # error, warning, info, debug, trace
    apiVersion: '1.5'
  })

if process.env.NODE_ENV is 'test'
  factories = require '../../test/factories/index'
  es.client.search = () ->
    new Promise (resolve, reject) -> resolve factories.elasticsearch.random_products([1..48])

module.exports = es
