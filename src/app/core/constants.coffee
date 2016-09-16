'use strict'

subtags =
  homeAccents: [
    'Home decor accents'
    'Wall Decor'
    'Mirrors'
    'Lamps, bases & shades'
    'Candles & holders'
    'Coat & hat racks'
    'Plants & Flowers'
    'Pillows'
    'General'
  ],
  furniture: [
    'Living room'
		'Dining room'
		'Kitchen'
		'Home entertainment'
		'Home office'
		'Bedroom'
		'Bean Bags'
		'Other'
  ],
  artwork: [
    'Artwork'
  ],
  bedBath: [
    'Quilts'
		'Bedding ensembles'
		# 'Sheets & pillowcases'
		'Blankets & throws'
		'Comforters'
		'Decorative pillows, inserts & covers'
		# 'Bedspreads & coverlets'
		# 'Down/Down Alternative'
		'Bathroom accessories'
		'Bathroom decorations'
		'Bath rugs & mats'
		'Towels & washcloths'
		# 'Bath linen sets'
  ],
  kitchen: [
    'Dinnerware & serving pieces'
    'Kitchen storage & organization'
    # 'Cookware'
    'Cutlery'
    'Linens'
    'Bar tools & glasses'
    # 'Flatware'
    # 'Glassware'
  ],
  outdoor: [
    'Patio furniture sets'
    'Chairs'
    'Tables'
    'Plants & planting'
    'Firepits'
    'Birdhouses & accessories'
    'Birdbaths'
    'Lights & lanterns'
    'Hammocks, stands & accessories'
    'Plaques'
    'General'
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
