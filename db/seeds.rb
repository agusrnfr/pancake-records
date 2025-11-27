require "open-uri"
puts "== Eliminando datos previos =="
User.destroy_all
Product.destroy_all
Genre.destroy_all
puts "== Creando usuarios =="

admin = User.create!(
  email: "admin@pancake.com",
  surname: "admin",
  password: "password123",
  name: "Administrador",
  role: :administrator
)

manager = User.create!(
  email: "gerente@pancake.com",
  surname: "gerente",
  password: "password123",
  name: "Gerente General",
  role: :manager
)

employee = User.create!(
  email: "empleado@pancake.com",
  surname: "empleado",
  password: "password123",
  name: "Empleado Demo",
  role: :employee
)

# genres = {
#   rock:      Genre.create!(name: "Rock"),
#   pop:       Genre.create!(name: "Pop"),
#   jazz:      Genre.create!(name: "Jazz"),
#   blues:     Genre.create!(name: "Blues"),
#   hiphop:    Genre.create!(name: "Hip-Hop"),
#   reggae:    Genre.create!(name: "Reggae"),
#   classical: Genre.create!(name: "Clásico"),
#   metal:     Genre.create!(name: "Metal"),
#   punk:      Genre.create!(name: "Punk"),
#   electronic: Genre.create!(name: "Electrónica")
# }

# puts "==== Creando Productos con imágenes ===="

# products = [
#   {
#     name: "Abbey Road",
#     author: "The Beatles",
#     description: "Edición remasterizada del legendario álbum.",
#     price: 7990,
#     stock: 8,
#     format: :cd,
#     condition: :brand_new,
#     genre: genres[:rock],
#     image_url: "https://upload.wikimedia.org/wikipedia/en/4/42/Beatles_-_Abbey_Road.jpg"
#   },
#   {
#     name: "Thriller",
#     author: "Michael Jackson",
#     description: "El álbum más vendido de la historia.",
#     price: 10200,
#     stock: 5,
#     format: :vinyl,
#     condition: :used,
#     genre: genres[:pop],
#     image_url: "https://upload.wikimedia.org/wikipedia/en/5/55/Michael_Jackson_-_Thriller.png"
#   },
#   {
#     name: "Kind of Blue",
#     author: "Miles Davis",
#     description: "Álbum icónico del jazz moderno.",
#     price: 9500,
#     stock: 10,
#     format: :cd,
#     condition: :brand_new,
#     genre: genres[:jazz],
#     image_url: "https://upload.wikimedia.org/wikipedia/en/9/9c/MilesDavisKindofBlue.jpg"
#   },
#   {
#     name: "Back in Black",
#     author: "AC/DC",
#     description: "Uno de los discos más influyentes del hard rock.",
#     price: 8700,
#     stock: 7,
#     format: :vinyl,
#     condition: :used,
#     genre: genres[:rock],
#     image_url: "https://upload.wikimedia.org/wikipedia/commons/3/3e/Acdc_Back_in_Black.png"
#   },
#   {
#     name: "Nevermind",
#     author: "Nirvana",
#     description: "El álbum que definió el movimiento grunge.",
#     price: 8900,
#     stock: 4,
#     format: :cd,
#     condition: :brand_new,
#     genre: genres[:rock],
#     image_url: "https://upload.wikimedia.org/wikipedia/en/b/b7/NirvanaNevermindalbumcover.jpg"
#   },
#   {
#     name: "Random Access Memories",
#     author: "Daft Punk",
#     description: "Ganador del Grammy al Álbum del Año.",
#     price: 12000,
#     stock: 6,
#     format: :vinyl,
#     condition: :brand_new,
#     genre: genres[:electronic],
#     image_url: "https://upload.wikimedia.org/wikipedia/en/a/a7/Random_Access_Memories.jpg"
#   },
#   {
#     name: "The Dark Side of the Moon",
#     author: "Pink Floyd",
#     description: "Un clásico eterno del rock progresivo.",
#     price: 11000,
#     stock: 3,
#     format: :vinyl,
#     condition: :used,
#     genre: genres[:rock],
#     image_url: "https://upload.wikimedia.org/wikipedia/en/3/3b/Dark_Side_of_the_Moon.png"
#   },
#   {
#     name: "Legend",
#     author: "Bob Marley",
#     description: "La mejor recopilación de Bob Marley.",
#     price: 7500,
#     stock: 12,
#     format: :cd,
#     condition: :brand_new,
#     genre: genres[:reggae],
#     image_url: "https://upload.wikimedia.org/wikipedia/en/6/6d/BobMarley-Legend.jpg"
#   },
#   {
#     name: "The Eminem Show",
#     author: "Eminem",
#     description: "Uno de los discos más exitosos de Eminem.",
#     price: 6800,
#     stock: 9,
#     format: :cd,
#     condition: :used,
#     genre: genres[:hiphop],
#     image_url: "https://upload.wikimedia.org/wikipedia/en/3/35/The_Eminem_Show.jpg"
#   },
#   {
#     name: "Rage Against the Machine",
#     author: "Rage Against the Machine",
#     description: "Rap metal con protesta social.",
#     price: 9000,
#     stock: 5,
#     format: :cd,
#     condition: :brand_new,
#     genre: genres[:metal],
#     image_url: "https://upload.wikimedia.org/wikipedia/en/7/73/RageAgainsttheMachine-RageAgainsttheMachine.jpg"
#   }
# ]

# products.each do |data|
#   p = Product.create!(
#     name: data[:name],
#     author: data[:author],
#     description: data[:description],
#     price: data[:price],
#     stock: data[:stock],
#     format: Product.formats[data[:format]],
#     condition: Product.conditions[data[:condition]],
#     genre_ids: data[:genre].id,
#     inventory_entry_date: Date.today - rand(10..40).days
#   )

#   file = URI.open(data[:image_url])
#   p.image.attach(io: file, filename: "#{data[:name].parameterize}.jpg")

#   puts "📀 Creado #{p.name} con imagen"
# end

# puts "==== Productos creados ===="

# puts "== Seed finalizado =="
