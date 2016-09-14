'use strict'

subtags =
  homeAccents: [
    'Home decor accents'
    'Wall Decor'
    'Mirrors'
    'Lamps, bases & shades'
    'Candles & holders'
    'Coat & hat racks'
    'Friendship/Family'
    'Plants & Flowers'
    'Pillows'
    'General'
    'Other'
  ],
  furniture: [
    'Living room'
		'Dining room'
		'Bedroom'
		'Kitchen'
		'Home entertainment'
		'Home office'
		'Bean Bags'
		'Other'
  ],
  artwork: [
    'Artwork'
  ],
  bedBath: [
    'Quilts'
		'Decorative pillows, inserts & covers'
		'Bedding ensembles'
		'Sheets & pillowcases'
		'Blankets & throws'
		'Comforters'
		'Bedspreads & coverlets'
		'Down/Down Alternative'
		'Bath rugs & mats'
		'Bathroom accessories'
		'Towels & washcloths'
		'Bath linen sets'
		'Bathroom decorations'
    'Other'
  ],
  kitchen: [
    'Dinnerware & serving pieces'
    'Kitchen storage & organization'
    'Cookware'
    'Cutlery'
    'Linens'
    'Bar tools & glasses'
    'Flatware'
    'Glassware'
    'Other'
  ],
  outdoor: [
    'General'
    'Plaques'
    'Plants & planting'
    'Birdhouses & accessories'
    'Birdbaths'
    'Hammocks, stands & accessories'
    'Firepits'
    'Patio furniture sets'
    'Chairs'
    'Tables'
    'Tents & accessories'
    'Lights & lanterns'
    'Camping furniture'
    'Sleeping bags'
    'Other'
  ]

angular.module 'app.core'
  .constant 'eeBackUrl', '@@eeBackUrl/v0/'
  .constant 'eeTidyUrl', '@@eeTidyUrl/v0/'
  .constant 'eeAdminUrl', '@@eeAdminUrl/v0/'
  .constant 'categories', [
    { id: 4, title: 'Home Accents', subtags: subtags.homeAccents }
    { id: 3, title: 'Furniture', subtags: subtags.furniture }
    { id: 1, title: 'Artwork', subtags: subtags.artwork }
    { id: 2, title: 'Bed & Bath', subtags: subtags.bedBath }
    { id: 5, title: 'Kitchen', subtags: subtags.kitchen }
    { id: 6, title: 'Outdoor', subtags: subtags.outdoor }
  ]
  .constant 'defaultMargins', [
    { min: 0,     max: 2499,      margin: 0.20 }
    { min: 2500,  max: 4999,      margin: 0.15 }
    { min: 5000,  max: 9999,      margin: 0.10 }
    { min: 10000, max: 19999,     margin: 0.07 }
    { min: 20000, max: 99999999,  margin: 0.05 }
  ]
