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


begin
  file = URI.open("https://avatars.githubusercontent.com/u/89029960?v=4")

  agus = User.create!(
    email: "agusrojasmc@gmail.com",
    password: "Password123*",
    name: "Agustina",
    surname: "Rojas",
    role: :administrator,
    address: "Calle Falsa 123"
  )

  agus.avatar.attach(
    io: file,
    filename: "agustina-rojas-avatar.jpg",
    content_type: "image/jpeg"
  )

  file.close

  puts "🧑‍💻 Usuario Agustina creado con avatar"
rescue => e
  puts "⚠️ Error al crear usuario Agustina: #{e.message}"
end

puts "== Creando géneros =="

genres = {
  rock:       Genre.create!(name: "Rock"),
  pop:        Genre.create!(name: "Pop"),
  jazz:       Genre.create!(name: "Jazz"),
  blues:      Genre.create!(name: "Blues"),
  hiphop:     Genre.create!(name: "Hip-Hop"),
  reggae:     Genre.create!(name: "Reggae"),
  classical:  Genre.create!(name: "Clásico"),
  metal:      Genre.create!(name: "Metal"),
  punk:       Genre.create!(name: "Punk"),
  electronic: Genre.create!(name: "Electrónica"),
	alternative: Genre.create!(name: "Alternativo"),
	folk: Genre.create!(name: "Folk"),
	country: Genre.create!(name: "Country"),
	pop_rock: Genre.create!(name: "Pop Rock"),
	indie_folk: Genre.create!(name: "Indie Folk"),
	alternative_pop: Genre.create!(name: "Pop alternativo"),
	electropop: Genre.create!(name: "Electropop"),
	indie_pop: Genre.create!(name: "Indie Pop"),
	alternative_rock: Genre.create!(name: "Rock alternativo"),
	numetal: Genre.create!(name: "Nu Metal"),
	baroque_pop: Genre.create!(name: "Pop barroco")
}

puts "==== Creando Productos con imágenes ===="

products = [
  {
    name: "Abbey Road",
    author: "The Beatles",
    description: "Edición remasterizada del legendario álbum.",
    price: 7990, stock: 8,
    format: :cd, condition: :brand_new,
    genre: [genres[:rock]],
    image_url: "https://upload.wikimedia.org/wikipedia/en/4/42/Beatles_-_Abbey_Road.jpg"
  },
  {
    name: "Thriller",
    author: "Michael Jackson",
    description: "El álbum más vendido de la historia.",
    price: 10200, stock: 5,
    format: :vinyl, condition: :used,
    genre: [genres[:pop]],
    image_url: "https://upload.wikimedia.org/wikipedia/en/5/55/Michael_Jackson_-_Thriller.png"
  },
  {
    name: "Kind of Blue",
    author: "Miles Davis",
    description: "Álbum icónico del jazz moderno.",
    price: 9500, stock: 10,
    format: :cd, condition: :brand_new,
    genre: [genres[:jazz]],
    image_url: "https://cdn-p.smehost.net/sites/c5d2b1a28fd246bfafed3b8dbafc1352/wp-content/uploads/2014/12/Kind-Of-Blue-50th-Anniv-final-cover.jpg"
  },
  {
    name: "Back in Black",
    author: "AC/DC",
    description: "Uno de los discos más influyentes del hard rock.",
    price: 8700, stock: 7,
    format: :vinyl, condition: :used,
    genre: [genres[:rock]],
    image_url: "https://upload.wikimedia.org/wikipedia/commons/9/9b/ACDC_Back_in_Black_Album_Cover_1980s_US_CD_reissue.jpg"
  },
  {
    name: "Nevermind",
    author: "Nirvana",
    description: "El álbum que definió el movimiento grunge.",
    price: 8900, stock: 4,
    format: :cd, condition: :brand_new,
    genre: [genres[:rock]],
    image_url: "https://upload.wikimedia.org/wikipedia/en/b/b7/NirvanaNevermindalbumcover.jpg"
  },
  {
    name: "Random Access Memories",
    author: "Daft Punk",
    description: "Ganador del Grammy al Álbum del Año.",
    price: 12000, stock: 6,
    format: :vinyl, condition: :brand_new,
    genre: [genres[:electronic]],
    image_url: "https://cdn-images.dzcdn.net/images/cover/311bba0fc112d15f72c8b5a65f0456c1/500x500.jpg"
  },
  {
    name: "The Dark Side of the Moon",
    author: "Pink Floyd",
    description: "Un clásico eterno del rock progresivo.",
    price: 11000, stock: 3,
    format: :vinyl, condition: :used,
    genre: [genres[:rock]],
    image_url: "https://upload.wikimedia.org/wikipedia/en/3/3b/Dark_Side_of_the_Moon.png"
  },
  {
    name: "The Eminem Show",
    author: "Eminem",
    description: "Uno de los discos más exitosos de Eminem.",
    price: 6800, stock: 9,
    format: :cd, condition: :used,
    genre: [genres[:hiphop]],
    image_url: "https://upload.wikimedia.org/wikipedia/en/3/35/The_Eminem_Show.jpg"
  },
  {
    name: "Rage Against the Machine",
    author: "Rage Against the Machine",
    description: "Rap metal con protesta social.",
    price: 9000, stock: 5,
    format: :cd, condition: :brand_new,
    genre: [genres[:metal], genres[:rock]],
    image_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/9/9e/Rage_Against_the_Machine_cover.jpg/1200px-Rage_Against_the_Machine_cover.jpg"
  },
  {
    name: "Taylor Swift",
    author: "Taylor Swift",
    description: "Álbum debut de Taylor Swift.",
    price: 8200, stock: 10,
    format: :cd, condition: :brand_new,
    genre: [genres[:pop], genres[:country]],
    image_url: "https://upload.wikimedia.org/wikipedia/en/1/1f/Taylor_Swift_-_Taylor_Swift.png"
  },
  {
    name: "Fearless (Taylor's Version)",
    author: "Taylor Swift",
    description: "Uno de los discos más premiados de Taylor Swift.",
    price: 8700, stock: 8,
    format: :cd, condition: :brand_new,
    genre: [genres[:pop], genres[:country]],
    image_url: "https://media.newyorker.com/photos/60747954c920e996bd1e486d/master/pass/Battan-FearlessTaylorsVersion.jpg"
  },
  {
    name: "Speak Now",
    author: "Taylor Swift",
    description: "Tercer álbum de estudio, completamente compuesto por ella.",
    price: 8900, stock: 7,
    format: :cd, condition: :used,
    genre: [genres[:pop], genres[:country], genres[:pop_rock]],
    image_url: "https://upload.wikimedia.org/wikipedia/en/8/8f/Taylor_Swift_-_Speak_Now_cover.png"
  },
  {
    name: "Red",
    author: "Taylor Swift",
    description: "Álbum que mezcla pop, country y rock.",
    price: 9000, stock: 10,
    format: :vinyl, condition: :brand_new,
    genre: [genres[:pop], genres[:country]],
    image_url: "https://upload.wikimedia.org/wikipedia/en/e/e8/Taylor_Swift_-_Red.png"
  },
  {
    name: "1989",
    author: "Taylor Swift",
    description: "Cambio definitivo al pop.",
    price: 10000, stock: 5,
    format: :vinyl, condition: :brand_new,
    genre: [genres[:pop], genres[:electropop]],
    image_url: "https://upload.wikimedia.org/wikipedia/en/f/f6/Taylor_Swift_-_1989.png"
  },
  {
    name: "Reputation",
    author: "Taylor Swift",
    description: "Un disco oscuro y experimental.",
    price: 9500, stock: 6,
    format: :cd, condition: :brand_new,
    genre: [genres[:pop], genres[:electropop]],
    image_url: "https://upload.wikimedia.org/wikipedia/en/f/f2/Taylor_Swift_-_Reputation.png"
  },
  {
    name: "Lover",
    author: "Taylor Swift",
    description: "Un álbum más colorido y romántico.",
    price: 9900, stock: 9,
    format: :cd, condition: :brand_new,
    genre: [genres[:pop], genres[:pop_rock]],
    image_url: "https://upload.wikimedia.org/wikipedia/en/c/cd/Taylor_Swift_-_Lover.png"
  },
  {
    name: "Folklore",
    author: "Taylor Swift",
    description: "Un giro indie y alternativo.",
    price: 10500, stock: 3,
    format: :vinyl, condition: :used,
    genre: [genres[:alternative_pop], genres[:indie_folk], genres[:alternative]],
    image_url: "https://is1-ssl.mzstatic.com/image/thumb/Music125/v4/ca/f3/67/caf367a5-2cf6-6b2e-a891-97dc57b19f08/20UMGIM64216.rgb.jpg/1200x630bf-60.jpg"
  },
  {
    name: "Evermore",
    author: "Taylor Swift",
    description: "Álbum hermano de Folklore.",
    price: 10500, stock: 4,
    format: :vinyl, condition: :brand_new,
    genre: [genres[:alternative_pop], genres[:indie_folk], genres[:alternative]],
    image_url: "https://cdn-images.dzcdn.net/images/cover/5bced293f3a0568a5f5111f92cbca47f/0x1900-000000-80-0-0.jpg"
  },
  {
    name: "Midnights",
    author: "Taylor Swift",
    description: "Nuevo estilo synth-pop moderno.",
    price: 11500, stock: 8,
    format: :vinyl, condition: :brand_new,
    genre: [genres[:pop], genres[:electropop]],
    image_url: "https://upload.wikimedia.org/wikipedia/en/9/9f/Midnights_-_Taylor_Swift.png"
  },
  {
    name: "Born to Die",
    author: "Lana Del Rey",
    description: "Su álbum más icónico.",
    price: 8500, stock: 10,
    format: :cd, condition: :brand_new,
    genre: [genres[:pop], genres[:indie_pop], genres[:alternative_rock]],
    image_url: "https://umusicstore.com.ar/cdn/shop/files/00602547934888-cover-zoom.jpg"
  },
  {
    name: "Ultraviolence",
    author: "Lana Del Rey",
    description: "Un disco oscuro y cinematográfico.",
    price: 9000, stock: 5,
    format: :vinyl, condition: :used,
    genre: [genres[:rock], genres[:alternative], genres[:alternative_rock]],
    image_url: "https://cdn-images.dzcdn.net/images/cover/b68adb6788dfa09a314f594aec287850/1900x1900-000000-80-0-0.jpg"
  },
  {
    name: "Honeymoon",
    author: "Lana Del Rey",
    description: "Atmosférico y elegante.",
    price: 9200, stock: 6,
    format: :cd, condition: :brand_new,
    genre: [genres[:pop], genres[:alternative], genres[:baroque_pop]],
    image_url: "https://umusicstore.com.ar/cdn/shop/products/HON.jpg?v=1634687071"
  },
  {
    name: "Norman Fucking Rockwell!",
    author: "Lana Del Rey",
    description: "Aclamado por la crítica.",
    price: 10000, stock: 4,
    format: :vinyl, condition: :brand_new,
    genre: [genres[:pop], genres[:rock], genres[:alternative_rock], genres[:indie_pop]],
    image_url: "https://cdn-images.dzcdn.net/images/cover/c0f4f022fa51f13e877aae2e758e241d/0x1900-000000-80-0-0.jpg"
  },
  {
    name: "Little Earthquakes",
    author: "Tori Amos",
    description: "Debut solista con fuerte impacto.",
    price: 8200, stock: 7,
    format: :cd, condition: :used,
    genre: [genres[:alternative], genres[:folk], genres[:indie_folk]],
    image_url: "https://cdn-images.dzcdn.net/images/cover/7f123b48a2730d0f7fe3226b2c9b58f4/1900x1900-000000-80-0-0.jpg"
  },
  {
    name: "Under the Pink",
    author: "Tori Amos",
    description: "Un viaje artístico emocional.",
    price: 8300, stock: 9,
    format: :cd, condition: :brand_new,
    genre: [genres[:rock], genres[:baroque_pop], genres[:alternative_rock], genres[:alternative]],
    image_url: "https://cdn-images.dzcdn.net/images/cover/12604e7f58422fcd417ddbd4fabeabd4/0x1900-000000-80-0-0.jpg"
  },
  {
    name: "Boys for Pele",
    author: "Tori Amos",
    description: "Experimental y profundo.",
    price: 8800, stock: 4,
    format: :vinyl, condition: :used,
    genre: [genres[:rock], genres[:alternative], genres[:alternative_rock], genres[:electronic], genres[:folk]],
    image_url: "https://cdn-images.dzcdn.net/images/cover/6bd1d8c5b3af2dc0321e96cfb8bd9fae/0x1900-000000-80-0-0.jpg"
  },
  {
    name: "From the Choirgirl Hotel",
    author: "Tori Amos",
    description: "Más electrónico y moderno.",
    price: 8500, stock: 6,
    format: :cd, condition: :brand_new,
    genre: [genres[:alternative_rock], genres[:rock], genres[:electronic]],
    image_url: "https://upload.wikimedia.org/wikipedia/en/3/3c/FromTheChoirgirl.jpg"
  },
	{
		name: "Scarlet's Walk",
		author: "Tori Amos",
		description: "Un viaje sonoro a través de la vida y el amor.",
		price: 8700, stock: 5,
		format: :cd, condition: :brand_new,
		genre: [genres[:alternative], genres[:baroque_pop], genres[:alternative_rock]],
		image_url: "https://upload.wikimedia.org/wikipedia/en/a/ad/Scarlets_Walk_cover.jpg"
	},
  {
    name: "Fallen",
    author: "Evanescence",
    description: "El disco que los llevó a la fama mundial.",
    price: 8800, stock: 9,
    format: :cd, condition: :brand_new,
    genre: [genres[:metal], genres[:numetal]],
    image_url: "https://upload.wikimedia.org/wikipedia/en/2/25/Evanescence_-_Fallen.png"
  },
  {
    name: "The Open Door",
    author: "Evanescence",
    description: "Más orquestal y personal.",
    price: 8700, stock: 5,
    format: :vinyl, condition: :used,
    genre: [genres[:metal], genres[:numetal]],
    image_url: "https://upload.wikimedia.org/wikipedia/en/0/04/Evanescence_-_The_Open_Door.png"
  },
  {
    name: "Synthesis",
    author: "Evanescence",
    description: "Reimaginaciones orquestales.",
    price: 9300, stock: 4,
    format: :cd, condition: :brand_new,
    genre: [genres[:metal], genres[:numetal]],
    image_url: "https://upload.wikimedia.org/wikipedia/en/8/86/Evanescence_-_Synthesis.png"
  },
  {
    name: "Thank U, Next",
    author: "Ariana Grande",
    description: "Uno de los discos más exitosos de Ariana Grande.",
    price: 9800, stock: 8,
    format: :cd, condition: :brand_new,
    genre: [genres[:pop], genres[:pop_rock]],
    image_urls: ["https://www.udiscovermusic.com/wp-content/uploads/2019/01/ariana-grande-album-cover-copy.jpg", "https://www.pepevinyl.com/wp-content/uploads/2024/07/ArianaThank1.jpg"],
    audio_file: "thank_u_next"
  },
  {
    name: "Positions",
    author: "Ariana Grande",
    description: "Álbum de estudio con un sonido más R&B y pop.",
    price: 9900, stock: 0,
    format: :cd, condition: :brand_new,
    genre: [genres[:pop], genres[:pop_rock]],
    image_urls: ["https://upload.wikimedia.org/wikipedia/en/a/a0/Ariana_Grande_-_Positions.png", "https://i.pinimg.com/736x/e9/aa/92/e9aa92a5b62eb190de0a0b9ed357f4be.jpg"],
    audio_file: "positions"
  },
  {
    name: "Eternal Sunshine (Deluxe Edition)",
    author: "Ariana Grande",
    description: "Edición deluxe de Eternal Sunshine.",
    price: 11500, stock: 5,
    format: :vinyl, condition: :brand_new,
    genre: [genres[:pop], genres[:electropop]],
    image_urls: ["https://upload.wikimedia.org/wikipedia/en/1/12/Ariana_Grande_%E2%80%93_Eternal_Sunshine_Deluxe_%28album_cover%29.png", "https://suffragetterecords.com.au/cdn/shop/files/ariana2.jpg?v=1744017588&width=1445"],
    audio_file: "eternal_sunshine_deluxe"
  },
  {
    name: "Preacher's Daughter",
    author: "Ethel Cain",
    description: "Álbum conceptual con influencias de dream pop, gospel y rock alternativo.",
    price: 9200, stock: 5,
    format: :vinyl, condition: :brand_new,
    genre: [genres[:alternative], genres[:indie_folk]],
    image_urls: ["https://upload.wikimedia.org/wikipedia/en/7/74/Preachers_daughter_ethel_cain.png", "https://static.wikia.nocookie.net/ethel-cain/images/7/72/PD_%28Back_Cover%29.jpg/revision/latest/scale-to-width-down/250?cb=20251031195239"]
  }

]

products.each do |data|
  begin
    product = Product.new(
      name: data[:name],
      author: data[:author],
      description: data[:description],
      price: data[:price],
      stock: data[:stock],
      format: data[:format],
      condition: data[:condition],
      genre_ids: data[:genre].map(&:id),
      inventory_entry_date: Date.today - rand(10..40).days
    )

    image_urls = Array(data[:image_urls] || data[:image_url])

    image_urls.each_with_index do |image_url, index|
      file = URI.open(image_url)

      product.images.attach(
        io: file,
        filename: index.zero? ? "#{data[:name].parameterize}.jpg" : "#{data[:name].parameterize}-#{index + 1}.jpg",
        content_type: "image/jpeg"
      )
    end

    if data[:audio_file].present?
      audio_path = Rails.root.join("db", "seeds", "audio", "#{data[:audio_file]}.mp3")

      if File.exist?(audio_path)
        audio_file = File.open(audio_path)

        product.audio_sample.attach(
          io: audio_file,
          filename: File.basename(audio_path),
          content_type: "audio/mpeg"
        )

        puts "🎧 Audio adjuntado para #{product.name}"
      else
        puts "⚠️  Archivo de audio no encontrado para #{product.name}: #{audio_path}"
      end
    end

    product.save!

    puts "📀 Creado #{product.name} con #{image_urls.size} imagen(es)"
  rescue => e
    puts "⚠️  Error al crear #{data[:name]}: #{e.message}"
  end
end

puts "==== Productos creados ===="
puts "== Seed finalizado =="
