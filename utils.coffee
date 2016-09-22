fns = {}

fns.setStatus = (section, status) ->
  global.ee_status ||= {}
  return unless section? and status?
  global.ee_status[section] = status
  console.log global.ee_status
  global.ee_status

fns.timestamp = () ->
  # 2016-03-30 03:32:47PM
  dateNow = new Date()
  hours = dateNow.getHours()
  ampm  = if hours >= 12 then 'PM' else 'AM'
  if hours >= 12 then hours -= 12
  dateNow.getFullYear() + '-' +
    ('0' + (dateNow.getMonth()+1)).slice(-2) + '-' +
    ('0' + dateNow.getDate()).slice(-2) + ' ' +
    ('0' + hours).slice(-2) + ':' +
    ('0' + dateNow.getMinutes()).slice(-2) + ':' +
    ('0' + dateNow.getSeconds()).slice(-2) + ampm

# fns.currentTime = () ->
#   dateNow = new Date()
#   hours = dateNow.getHours()
#   ampm  = if hours >= 12 then 'PM' else 'AM'
#   if hours >= 12 then hours -= 12
#   '' + hours + ':' + ('0' + dateNow.getMinutes()).slice(-2) + ':' + ('0' + dateNow.getSeconds()).slice(-2) + ampm

fns.fileTimestamp = () ->
  fns.timestamp().slice(0,23).replace(/[:\.]/g,'-').replace(/ /g,'_')

fns.getFilename = (file_path) ->
  path_parts = file_path.split('/')
  path_parts[path_parts.length - 1]

fns.timestampedFilename = (file_path, insertStr) ->
  insertStr ||= '_'
  filename  = fns.getFilename(file_path)
  splitAt   = filename.lastIndexOf('.')
  name      = filename.substring(0, splitAt)
  extension = filename.substring(splitAt)
  name + insertStr + fns.fileTimestamp() + extension

fns.dollarsToCents = (dollars) ->
  dollars = parseFloat dollars
  parseInt(dollars * 100)

fns.tagText = (txt) ->
  txt.replace(/é/, 'e').toLowerCase().replace(/[^a-z ]/g, '').replace(/ +/g, '-')

module.exports = fns
