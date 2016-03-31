fns = {}

fns.timestamp = () ->
  # 2016-03-30 00:29:47.280 +00:00
  dateNow = new Date()
  dateNow.getUTCFullYear() + '-' +
    ('0' + (dateNow.getUTCMonth()+1)).slice(-2) + '-' +
    ('0' + dateNow.getUTCDate()).slice(-2) + ' ' +
    ('0' + dateNow.getUTCHours()).slice(-2) + ':' +
    ('0' + dateNow.getUTCMinutes()).slice(-2) + ':' +
    ('0' + dateNow.getUTCSeconds()).slice(-2) + '.' +
    ('00' + dateNow.getUTCMilliseconds()).slice(-3) + ' ' +
    '+00:00'

fns.fileTimestamp = () ->
  fns.timestamp().slice(0,23).replace(/[:\.]/g,'').replace(/ /g,'_')

module.exports = fns
