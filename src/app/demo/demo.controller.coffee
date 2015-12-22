'use strict'

angular.module('app.core').controller 'demoCtrl', () ->

  demo = this

  demo.meta =
    name: 'Example'
    brand:
      color:
        primary: '#555'
        tertiary: '#FFF'
    about: headline: '1'
    blog: url: '1'
    audience:
      social: { facebook: '1', twitter: '1', pinterest: '1', instagram: '1' }

  demo.collections = [
    {
      title: 'nautical'
      headline: 'Your inner sailor'
      button: 'Shop nautical'
      banner: 'https://res.cloudinary.com/eeosk-team/image/upload/c_crop,g_xy_center,h_200,w_400,x_390,y_160/v1436838757/excellent-nautical-living-room-on-living-room-at-nautical-living-room_ogpruo.png'
      min_price: 2299
      max_price: 14499
      avg_price: 7888
      avg_earnings: 671
      max_sale: 25
      selection_images: [
        'https://res.cloudinary.com/eeosk/image/upload/c_pad,w_70,h_70/v1433891015/rvsmsaz5szbqwdjjulva.jpg',
        'https://res.cloudinary.com/eeosk/image/upload/c_pad,w_70,h_70/v1433891094/hpvkacccur0hsyxxqa6w.jpg',
        'https://res.cloudinary.com/eeosk/image/upload/c_pad,w_70,h_70/v1433891109/o3nqomb4gnr06ku4xcja.jpg',
        'https://res.cloudinary.com/eeosk/image/upload/c_pad,w_70,h_70/v1433891143/xxdqhbwzblajuyobslmg.jpg',
        'https://res.cloudinary.com/eeosk/image/upload/c_pad,w_70,h_70/v1433891265/wigd1gph1cr7qzg8vado.jpg',
        'https://res.cloudinary.com/eeosk/image/upload/c_pad,w_70,h_70/v1433891144/xgjl1sfsk2w0qmliqc8j.jpg'
      ]
      selection_ids: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50]
      template_ids: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50]
    },
    {
      title: 'fun_bedding'
      headline: 'Back to school bedding'
      button: 'See the colors'
      banner: 'https://res.cloudinary.com/eeosk/image/upload/c_fill,w_400,h_200/v1429115091/lanxaprcneyjq4d7syqo.jpg'
      min_price: 9699
      max_price: 12799
      avg_price: 10282
      avg_earnings: 1239
      max_sale: 20
      selection_images: [
        'https://res.cloudinary.com/eeosk/image/upload/c_pad,w_70,h_70/v1429115063/c5smhguzidlq0edp0hkl.jpg',
        'https://res.cloudinary.com/eeosk/image/upload/c_pad,w_70,h_70/v1429115066/bzzfimkhntulfg2d8tc5.jpg',
        'https://res.cloudinary.com/eeosk/image/upload/c_pad,w_70,h_70/v1429115088/dfqbo0nwlb2zao5sxyxz.jpg',
        'https://res.cloudinary.com/eeosk/image/upload/c_pad,w_70,h_70/v1429115065/eyiz2pydn6jt6kz3ssu6.jpg',
        'https://res.cloudinary.com/eeosk/image/upload/c_pad,w_70,h_70/v1429115063/puawmj0mwflmuaogcdve.jpg',
        'https://res.cloudinary.com/eeosk/image/upload/c_pad,w_70,h_70/v1429115064/pzdnnrexpj4s1ygrosu3.jpg'
      ]
      selection_ids: [1,2,3,4,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50]
      template_ids: [1,2,3,4,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50]
    },
    {
      title: 'water_scenes'
      headline: 'Art on the water'
      button: 'Shop now'
      banner: 'https://res.cloudinary.com/eeosk/image/upload/c_fill,w_400,h_200/v1429114970/emhbhfxmxu5fmbykilvk.jpg'
      min_price: 3799
      max_price: 17999
      avg_price: 11423
      avg_earnings: 1442
      max_sale: 33
      selection_images: [
        'https://res.cloudinary.com/eeosk/image/upload/c_pad,w_70,h_70/v1429115002/avseisxqbkyb4rj3qflx.jpg',
        'https://res.cloudinary.com/eeosk/image/upload/c_pad,w_70,h_70/v1429115004/oeeorcegmq1ouigksdik.jpg',
        'https://res.cloudinary.com/eeosk/image/upload/c_pad,w_70,h_70/v1429115009/sxlj3cziot82csxy96ks.jpg',
        'https://res.cloudinary.com/eeosk/image/upload/c_pad,w_70,h_70/v1429114975/psmyun8qtzkdula8oj32.jpg',
        'https://res.cloudinary.com/eeosk/image/upload/c_pad,w_70,h_70/v1429114976/bzdetxgangjpehyokwtg.jpg',
        'https://res.cloudinary.com/eeosk/image/upload/c_pad,w_70,h_70/v1429115003/tvyzj99qjsnnnokz6pkk.jpg'
      ]
      selection_ids: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46]
      template_ids: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46]
    },
    {
      title: 'wood_grains'
      headline: 'Stylish wood grain furniture'
      button: 'Shop now'
      banner: 'https://res.cloudinary.com/eeosk-team/image/upload/c_crop,h_200,w_400/v1436838480/woodgrain_si5h6f.jpg'
      min_price: 4599
      max_price: 18999
      avg_price: 8875
      avg_earnings: 981
      max_sale: 25
      selection_images: [
        'https://res.cloudinary.com/eeosk/image/upload/c_pad,w_70,h_70/v1429115276/kozoqbnvdsb4jcojep0n.jpg',
        'https://res.cloudinary.com/eeosk/image/upload/c_pad,w_70,h_70/v1429115621/b16fmnjuafl5nz52uhya.jpg',
        'https://res.cloudinary.com/eeosk/image/upload/c_pad,w_70,h_70/v1433891036/hfcrlb2ztpotuifdeyxt.jpg',
        'https://res.cloudinary.com/eeosk/image/upload/c_pad,w_70,h_70/v1429115168/y3d9v5u3pmzyoaes3yco.jpg',
        'https://res.cloudinary.com/eeosk/image/upload/c_pad,w_70,h_70/v1433891009/ynwmhdf3baduehpnj3k4.jpg',
        'https://res.cloudinary.com/eeosk/image/upload/c_pad,w_70,h_70/v1433891127/ufp1crprwaovggxcyv17.jpg'
      ]
      selection_ids: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56]
      template_ids: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56]
    },
    {
      title: 'house_plaque_letters'
      headline: 'House Plaque Letters A-Z'
      button: 'Find your letter!'
      banner: 'https://res.cloudinary.com/eeosk/image/upload/c_pad,w_400,h_200/v1429115273/xcclhkjyeuqutfhnipyg.jpg'
      min_price: 3999
      max_price: 3999
      avg_price: 3999
      avg_earnings: 811
      max_sale: 33
      selection_images: [
        'https://res.cloudinary.com/eeosk/image/upload/c_pad,w_70,h_70/v1429115271/rydpfgsabx8hj8ec2grf.jpg',
        'https://res.cloudinary.com/eeosk/image/upload/c_pad,w_70,h_70/v1429115271/e7m0q8hqcpvchwtnsxok.jpg',
        'https://res.cloudinary.com/eeosk/image/upload/c_pad,w_70,h_70/v1429115271/vj7bf01uinmjkydxisxw.jpg',
        'https://res.cloudinary.com/eeosk/image/upload/c_pad,w_70,h_70/v1429115271/v6enqlhh37zxcdcrkyj8.jpg',
        'https://res.cloudinary.com/eeosk/image/upload/c_pad,w_70,h_70/v1429115271/lcuekbazsuud9rxgqqzk.jpg',
        'https://res.cloudinary.com/eeosk/image/upload/c_pad,w_70,h_70/v1429115271/tfzqtiiif3oowqmszemf.jpg'
      ]
      selection_ids: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26]
      template_ids: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26]
    },
    {
      title: 'office_containers'
      headline: 'Sip at your office in style'
      button: 'Shop now'
      banner: 'https://res.cloudinary.com/eeosk-team/image/upload/c_fit,h_200,w_400/v1436889209/stock-footage-happy-businesswoman-drinking-coffee-in-the-office_klv8is.jpg'
      min_price: 799
      max_price: 2799
      avg_price: 928
      avg_earnings: 213
      max_sale: 10
      selection_images: [
        'https://res.cloudinary.com/eeosk/image/upload/c_pad,w_70,h_70/v1429115618/ofiqzxf5kpxslmpr0aph.jpg',
        'https://res.cloudinary.com/eeosk/image/upload/c_pad,w_70,h_70/v1433891213/yhdt8ghbcs33lxm5tb7l.jpg',
        'https://res.cloudinary.com/eeosk/image/upload/c_pad,w_70,h_70/v1429115610/f55oakqbp0f9ukjsarfp.jpg',
        'https://res.cloudinary.com/eeosk/image/upload/c_pad,w_70,h_70/v1433891204/vmiyhr2orynd5trgqvyr.jpg',
        'https://res.cloudinary.com/eeosk/image/upload/c_pad,w_70,h_70/v1429115613/olzjjwvq5hhwle3pfm4p.jpg',
        'https://res.cloudinary.com/eeosk/image/upload/c_pad,w_70,h_70/v1433891205/lkpp7esvjbjg4bozwzcx.jpg'
      ]
      selection_ids: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25]
      template_ids: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25]
    },
    {
      title: 'ceramic_figurines'
      headline: 'Delightful ceramic figurines'
      button: 'Shop now'
      banner: 'https://res.cloudinary.com/eeosk/image/upload/c_fit,h_200,w_400/v1429115327/mrrnhwh5ovxfemvvbgw0.jpg'
      min_price: 3599
      max_price: 5599
      avg_price: 4291
      avg_earnings: 921
      max_sale: 15
      selection_images: [
        'https://res.cloudinary.com/eeosk/image/upload/c_pad,w_70,h_70/v1429115321/i95jpntagm0pwbbrvvjh.jpg',
        'https://res.cloudinary.com/eeosk/image/upload/c_pad,w_70,h_70/v1429115322/x1va1hei1xg5m5hexuv2.jpg',
        'https://res.cloudinary.com/eeosk/image/upload/c_pad,w_70,h_70/v1429115320/rwmc0zaml6uqxdig2ko7.jpg',
        'https://res.cloudinary.com/eeosk/image/upload/c_pad,w_70,h_70/v1429115324/v9tuzcuhhaukfxaqd29v.jpg',
        'https://res.cloudinary.com/eeosk/image/upload/c_pad,w_70,h_70/v1429115338/vnq2mddxflbske5dotu0.jpg',
        'https://res.cloudinary.com/eeosk/image/upload/c_pad,w_70,h_70/v1429115330/xwfzsxgbh6mn9aln07b8.jpg'
      ]
      selection_ids: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33]
      template_ids: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33]
    }
  ]

  return
