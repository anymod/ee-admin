fns = {}

fns.setStatus = (section, status) ->
  global.ee_status ||= {}
  return unless section and status
  global.ee_status[section] = status
  console.log global.ee_status

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

fns.getFilename = (file_path) ->
  path_parts = file_path.split('/')
  path_parts[path_parts.length - 1]

fns.getDatedFilename = (file_path) ->
  filename  = fns.getFilename(file_path)
  splitAt   = filename.lastIndexOf('.')
  name      = filename.substring(0, splitAt)
  extension = filename.substring(splitAt)
  name + '_processed-' + fns.fileTimestamp() + extension

fns.dollarsToCents = (dollars) ->
  dollars = parseFloat dollars
  parseInt(dollars * 100)

module.exports = fns
