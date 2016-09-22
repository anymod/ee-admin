mappings =

  sku:
    supplier_id: 'supplier_id'
    # drop_ship_fee: 'other.fee'
    supplier_name: 'supplier_name'
    product_id: 'other.product_id'
    product_sku: 'other.product_sku'
    warranty: 'meta.warranty'
    condition: 'meta.condition'
    details: 'details'
    manufacturer: 'manufacturer_name'
    brand_name: 'brand_name'
    # case_pack_quantity: ''
    country_of_origin: 'shipping_from'
    product_last_update: 'other.product_updated_at'
    item_id: 'other.item_id'
    item_sku: 'identifier'
    # mpn: ''
    upc: 'other.upc'
    item_name: 'selection_text'
    item_weight: 'weight'
    # ship_alone: ''
    # ship_freight: ''
    ship_weight: 'meta.shipping_weight'
    ship_cost: 'supply_shipping_price'
    # max_ship_single_box: ''
    # map: ''
    price: 'supply_price'
    # custom_price: ''
    # prepay_price: ''
    # street_price: ''
    msrp: 'msrp'
    qty_avail: 'quantity'
    stock: 'discontinued'
    # est_avail: ''
    # pending_order_quantity: ''
    # qty_on_order: ''
    item_last_update: 'other.updated_at'
    # item_discontinued_date: ''
    categories: 'other.categories'
    attributes: 'meta.attributes'
    image_file: 'other.image'
    # image_width: ''
    # image_height: ''
    additional_images: 'other.additional_images'
    # folder_paths: ''
    # is_customized: ''

  product:
    title: 'title'
    description: 'content'
    product_id: 'external_identity' # external_identity = 'DOBA.' + product_id
    image_file: 'image'
    additional_images: 'additional_images'

  tags1And2:
    'Home decor accents':             tags1: ['Décor'], tags2: ['Home Accents']
    'Wall Decor':                     tags1: ['Décor'], tags2: ['Wall Décor']
    'Mirrors':                        tags1: ['Décor'], tags2: ['Mirrors']
    'Lamps, bases & shades':          tags1: ['Lighting'], tags2: ['Lamps', 'Bulbs & Shades']
    'Candles & holders':              tags1: ['Décor'], tags2: ['Home Accents']
    'Coat & hat racks':               tags1: ['Furniture'], tags2: ['Entry & Mudroom']
    'Plants & Flowers':               tags1: ['Décor'], tags2: ['Home Accents']
    'Pillows':                        tags1: ['Décor'], tags2: ['Pillows & Throws']
    'Living room':                    tags1: ['Furniture'], tags2: ['Living Room']
    'Dining room':                    tags1: ['Furniture'], tags2: ['Kitchen & Dining']
    'Kitchen':                        tags1: ['Furniture'], tags2: ['Kitchen & Dining']
    'Home entertainment':             tags1: ['Furniture'], tags2: ['Game Room']
    'Home office':                    tags1: ['Furniture'], tags2: ['Office']
    'Bedroom':                        tags1: ['Furniture'], tags2: ['Bedroom']
    'Bean Bags':                      tags1: ['Furniture'], tags2: ['Accent']
    'Artwork':                        tags1: ['Décor'], tags2: ['Wall Décor']
    'Comforters':                     tags1: ['Bed & Bath'], tags2: ['Bedding']
    'Bedding ensembles':              tags1: ['Bed & Bath'], tags2: ['Bedding']
    'Quilts':                         tags1: ['Bed & Bath'], tags2: ['Bedding']
    'Blankets & throws':              tags1: ['Bed & Bath'], tags2: ['Bedding']
    'Decorative pillows, inserts & covers': tags1: ['Bed & Bath'], tags2: ['Bedding Basics']
    'Bathroom accessories':           tags1: ['Bed & Bath'], tags2: ['Bath Accessories']
    'Bathroom decorations':           tags1: ['Bed & Bath'], tags2: ['Bath Accessories']
    'Bath rugs & mats':               tags1: ['Bed & Bath'], tags2: ['Bath Linens']
    'Towels & washcloths':            tags1: ['Bed & Bath'], tags2: ['Bath Linens']
    'Dinnerware & serving pieces':    tags1: ['Kitchen'], tags2: ['Tableware']
    'Kitchen storage & organization': tags1: ['Kitchen'], tags2: ['Storage & Organization']
    'Cutlery':                        tags1: ['Kitchen'], tags2: ['Cutlery & Prep']
    'Linens':                         tags1: ['Kitchen'], tags2: ['Tableware']
    'Bar tools & glasses':            tags1: ['Kitchen'], tags2: ['Bar & Wine']
    'Chairs':                         tags1: ['Outdoor', 'Furniture'], tags2: ['Patio Furniture', 'Patio']
    'Tables':                         tags1: ['Outdoor', 'Furniture'], tags2: ['Patio Furniture', 'Patio']
    'Patio furniture sets':           tags1: ['Outdoor', 'Furniture'], tags2: ['Patio Furniture', 'Patio']
    'Plants & planting':              tags1: ['Outdoor'], tags2: ['Lawn & Garden']
    'Firepits':                       tags1: ['Outdoor'], tags2: ['Outdoor Heating']
    'Birdhouses & accessories':       tags1: ['Outdoor'], tags2: ['Outdoor Décor']
    'Birdbaths':                      tags1: ['Outdoor'], tags2: ['Outdoor Décor']
    'Lights & lanterns':              tags1: ['Lighting'], tags2: ['Outdoor Lighting']
    'Hammocks, stands & accessories': tags1: ['Outdoor'], tags2: ['Patio Furniture']
    'Plaques':                        tags1: ['Outdoor'], tags2: ['Outdoor Décor']


module.exports = mappings
