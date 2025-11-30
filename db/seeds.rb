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
  address: "Calle Falsa 123",
  role: :administrator
)

manager = User.create!(
  email: "gerente@pancake.com",
  surname: "gerente",
  password: "password123",
  name: "Gerente General",
  address: "Calle Falsa 123",
  role: :manager
)

employee = User.create!(
  email: "empleado@pancake.com",
  surname: "empleado",
  password: "password123",
  name: "Empleado Demo",
  address: "Calle Falsa 123",
  role: :employee
)

User.create!(
  email: "lucas.fernandez@pancake.com",
  surname: "Fernández",
  password: "123456",
  name: "Lucas",
  address: "Calle San Martín 1020, Rosario",
  role: :administrator
)

User.create!(
  email: "camila.rodriguez@pancake.com",
  surname: "Rodríguez",
  password: "123456",
  name: "Camila",
  address: "Bv. Oroño 340, Córdoba",
  role: :administrator
)


User.create!(
  email: "valentina.perez@pancake.com",
  surname: "Pérez",
  password: "123456",
  name: "Valentina",
  address: "Av. Pellegrini 1200, Rosario",
  role: :manager
)

User.create!(
  email: "diego.alvarez@pancake.com",
  surname: "Álvarez",
  password: "123456",
  name: "Diego",
  address: "Calle Belgrano 760, Mar del Plata",
  role: :manager
)

User.create!(
  email: "julieta.ramos@pancake.com",
  surname: "Ramos",
  password: "123456",
  name: "Julieta",
  address: "Av. Santa Fe 2300, Buenos Aires",
  role: :manager
)

User.create!(
  email: "nicolas.garcia@pancake.com",
  surname: "García",
  password: "123456",
  name: "Nicolás",
  address: "Calle Mitre 500, Salta",
  role: :manager
)

User.create!(
  email: "sofia.gomez@pancake.com",
  surname: "Gómez",
  password: "123456",
  name: "Sofía",
  address: "Av. Rivadavia 1120, Buenos Aires",
  role: :employee
)

User.create!(
  email: "juan.cruz@pancake.com",
  surname: "Cruz",
  password: "123456",
  name: "Juan",
  address: "Calle Catamarca 450, Mendoza",
  role: :employee
)

User.create!(
  email: "florencia.suarez@pancake.com",
  surname: "Suárez",
  password: "123456",
  name: "Florencia",
  address: "Av. Alem 320, Tucumán",
  role: :employee
)

User.create!(
  email: "tomas.martinez@pancake.com",
  surname: "Martínez",
  password: "123456",
  name: "Tomás",
  address: "Calle Roca 190, Rosario",
  role: :employee
)

User.create!(
  email: "maria.castro@pancake.com",
  surname: "Castro",
  password: "123456",
  name: "María",
  address: "Av. San Juan 880, Buenos Aires",
  role: :employee
)

User.create!(
  email: "agustin.sosa@pancake.com",
  surname: "Sosa",
  password: "123456",
  name: "Agustín",
  address: "Calle Alberdi 250, La Plata",
  role: :employee
)

genres = {
  rock:      Genre.create!(name: "Rock"),
  pop:       Genre.create!(name: "Pop"),
  jazz:      Genre.create!(name: "Jazz"),
  blues:     Genre.create!(name: "Blues"),
  hiphop:    Genre.create!(name: "Hip-Hop"),
  reggae:    Genre.create!(name: "Reggae"),
  classical: Genre.create!(name: "Clásico"),
  metal:     Genre.create!(name: "Metal"),
  punk:      Genre.create!(name: "Punk"),
  electronic: Genre.create!(name: "Electrónica")
}

puts "==== Creando Productos con imágenes ===="

products = [
  {
    name: "Abbey Road",
    author: "The Beatles",
    description: "Edición remasterizada del legendario álbum.",
    price: 7990,
    stock: 8,
    format: :cd,
    condition: :brand_new,
    genre: genres[:rock],
    images: "https://upload.wikimedia.org/wikipedia/en/4/42/Beatles_-_Abbey_Road.jpg"
  },
  {
    name: "Thriller",
    author: "Michael Jackson",
    description: "El álbum más vendido de la historia.",
    price: 10200,
    stock: 5,
    format: :vinyl,
    condition: :used,
    genre: genres[:pop],
    images: "https://upload.wikimedia.org/wikipedia/en/5/55/Michael_Jackson_-_Thriller.png"
  },
  {
    name: "Kind of Blue",
    author: "Miles Davis",
    description: "Álbum icónico del jazz moderno.",
    price: 9500,
    stock: 10,
    format: :cd,
    condition: :brand_new,
    genre: genres[:jazz],
    images: "https://upload.wikimedia.org/wikipedia/en/9/9c/MilesDavisKindofBlue.jpg"
  },
  {
    name: "Back in Black",
    author: "AC/DC",
    description: "Uno de los discos más influyentes del hard rock.",
    price: 8700,
    stock: 7,
    format: :vinyl,
    condition: :used,
    genre: genres[:rock],
    images: "https://upload.wikimedia.org/wikipedia/commons/3/3e/Acdc_Back_in_Black.png"
  },
  {
    name: "Nevermind",
    author: "Nirvana",
    description: "El álbum que definió el movimiento grunge.",
    price: 8900,
    stock: 4,
    format: :cd,
    condition: :brand_new,
    genre: genres[:rock],
    images: "https://upload.wikimedia.org/wikipedia/en/b/b7/NirvanaNevermindalbumcover.jpg"
  },
  {
    name: "Random Access Memories",
    author: "Daft Punk",
    description: "Ganador del Grammy al Álbum del Año.",
    price: 12000,
    stock: 6,
    format: :vinyl,
    condition: :brand_new,
    genre: genres[:electronic],
    images: "https://upload.wikimedia.org/wikipedia/en/a/a7/Random_Access_Memories.jpg"
  },
  {
    name: "The Dark Side of the Moon",
    author: "Pink Floyd",
    description: "Un clásico eterno del rock progresivo.",
    price: 11000,
    stock: 3,
    format: :vinyl,
    condition: :used,
    genre: genres[:rock],
    images: "https://upload.wikimedia.org/wikipedia/en/3/3b/Dark_Side_of_the_Moon.png"
  },
  {
    name: "Legend",
    author: "Bob Marley",
    description: "La mejor recopilación de Bob Marley.",
    price: 7500,
    stock: 12,
    format: :cd,
    condition: :brand_new,
    genre: genres[:reggae],
    images: "https://upload.wikimedia.org/wikipedia/en/6/6d/BobMarley-Legend.jpg"
  },
  {
    name: "The Eminem Show",
    author: "Eminem",
    description: "Uno de los discos más exitosos de Eminem.",
    price: 6800,
    stock: 9,
    format: :cd,
    condition: :used,
    genre: genres[:hiphop],
    images: "https://upload.wikimedia.org/wikipedia/en/3/35/The_Eminem_Show.jpg"
  },
  {
    name: "Rage Against the Machine",
    author: "Rage Against the Machine",
    description: "Rap metal con protesta social.",
    price: 9000,
    stock: 5,
    format: :cd,
    condition: :brand_new,
    genre: genres[:metal],
    images: "https://upload.wikimedia.org/wikipedia/en/7/73/RageAgainsttheMachine-RageAgainsttheMachine.jpg"
  }
]

products.each do |data|
  begin
    # Intentar descargar la imagen primero
    file = URI.open(data[:images])
    
    p = Product.new(
      name: data[:name],
      author: data[:author],
      description: data[:description],
      price: data[:price],
      stock: data[:stock],
      format: Product.formats[data[:format]],
      condition: Product.conditions[data[:condition]],
      genre_ids: data[:genre].id,
      inventory_entry_date: Date.today - rand(10..40).days
    )
    
    p.images.attach(io: file, filename: "#{data[:name].parameterize}.jpg")
    file.close
    p.save!
    
    puts "📀 Creado #{p.name} con imagen"
  rescue => e
    puts "⚠️  Error al crear #{data[:name]}: #{e.message}"
    puts "   Saltando este producto..."
  end
end

puts "==== Productos creados ===="

puts "== Seed finalizado =="
