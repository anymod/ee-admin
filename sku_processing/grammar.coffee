_ = require 'lodash'

fns = {}

fns.removeHtmlMarkup = (str) ->
  return unless str?
  str = str
    .replace(/<br[^>]*>/g, '\n')
    .replace(/<p[^>]*>/g, '\n')
    .replace(/<li>/g, '\n')
    .replace(/<[^>]*>/g, '')

fns.removeCommonTypos = (str) ->
  return unless str?
  str = str
    .replace(/(&trade;|&#8482;|&copy;|&#169;|&reg;|&#174;)/g, '') # ASCII ™, ©, ®
    .replace(/(&quot;|&#34;)/g, '"') # ASCII quotation mark
    .replace(/(&#38;|&amp;)/g, '&') # ASCII Ampersand
    .replace(/(&#62;|&gt;)/g, '>') # ASCII >
    .replace(/(&#60;|&lt;)/g, '<') # ASCII <
    .replace(/(&#192;|&#193;|&#194;|&#195;|&#196;|&#197;)/g, 'A') # À, Á, Â, etc
    .replace(/(&#224;|&#225;|&#226;|&#227;|&#228;|&#229;)/g, 'A') # à, á, â, etc
    .replace(/(&#200;|&#201;|&#202;|&#203;)/g, 'E') # È, É, Ê, etc
    .replace(/(&#232;|&#233;|&#234;|&#235;)/g, 'e') # è, é, ê, etc
    .replace(/&apos;|&#39;/g, "'") # Apostrophe
    .replace(/\?s|`s/g, "'s") # Question mark or ` in place of apostrophe
    .replace(/("+)/g, '"') # Multiple quotation marks in a row
    .replace(/('{2,})/g, '"') # Multiple single quotes in a row
    .replace(/ 1 EA/gi, ' 1 EA\n') # 1 EA missing space after
    .replace(/ 1 SET/gi, ' 1 SET\n') # 1 SET missing space after
    .replace(/,(?=[^ ])/g, ', ') # Comma without space after it
    .replace(/(\n){3,}/g, '\n\n') # Too many newlines

fns.cleanTitle = (str) ->
  str = fns.removeCommonTypos str
  str = str
    .replace(/\n/g, '') # Remove newlines
    .replace(/\//g, ' / ') # Space between slashes
    .replace(/ w \/ /gi, ' with ') # w /
    .replace(/\t/g, ' ') # Tabs
    .replace(/ {2,}/, ' ') # Remove multiple spaces
    .trim()
  str

fns.cleanString = (str) ->
  str = fns.removeHtmlMarkup str
  str = fns.removeCommonTypos str
  str

fns.cleanProduct = (product) ->
  return unless product?.title? and product.content?
  product.title   = fns.cleanTitle product.title
  product.content = fns.cleanString product.content

fns.cleanSku = (sku) ->
  return unless sku?.selection_text?
  sku.selection_text = fns.cleanTitle sku.selection_text

fns.cleanPair = (pair) ->
  fns.cleanSku pair.sku
  fns.cleanProduct pair.product

fns.cleanPairs = (pairs) ->
  fns.cleanPair pair for pair in pairs

module.exports = fns
