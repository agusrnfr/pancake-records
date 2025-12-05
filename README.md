# 💿 Pancake Records

Sistema de gestión para una tienda de discos en vinilo y CD, desarrollado con Ruby on Rails. Incluye un catálogo público para clientes y un panel administrativo completo para la gestión de productos, ventas, usuarios y reportes.

## 📋 Descripción

**Pancake Records** es una aplicación web que permite:

- **Catálogo público**: Búsqueda y visualización de discos con filtros por género, formato, condición y año
- **Panel administrativo**: Gestión completa de:
  - **Discos**: CRUD completo, gestión de stock, imágenes múltiples, muestras de audio, géneros
  - **Ventas**: Creación de ventas, gestión de compradores, cancelación de ventas, exportación a PDF
  - **Usuarios**: Gestión de usuarios con roles (Administrador, Gerente, Empleado) y permisos
  - **Reportes**: Análisis de ventas con gráficos interactivos, KPIs y exportación a PDF

## 🛠️ Tecnologías

- **Ruby**: 3.4.5
- **Rails**: 8.1.1
- **Base de datos**: SQLite3
- **Autenticación**: Devise
- **Autorización**: CanCanCan
- **Búsqueda**: Ransack
- **Paginación**: Kaminari
- **Gráficos**: Chartkick + Chart.js
- **PDFs**: Prawn
- **Frontend**: Stimulus.js, Turbo, CSS personalizado

## 📦 Requisitos Previos

- Ruby 3.4.5 (recomendado usar [rbenv](https://github.com/rbenv/rbenv) o [rvm](https://rvm.io/))
- Bundler
- SQLite3
- Node.js (para importmap)

## 🚀 Instalación y Configuración

### 1. Clonar el repositorio

```bash
git clone https://github.com/agusrnfr/pancake-records.git
cd pancake-records
```

### 2. Instalar dependencias

```bash
bundle install
```

### 3. Configurar la base de datos

```bash
# Crear la base de datos
rails db:create

# Ejecutar migraciones
rails db:migrate

# Cargar datos iniciales (usuarios, géneros, productos y ventas de ejemplo)
rails db:seed
```

**Nota**: Si necesitas resetear la base de datos completamente (eliminar todo y recrear):

```bash
rails db:reset
```

Este comando ejecuta `db:drop`, `db:create`, `db:migrate` y `db:seed` en secuencia.

### 4. Iniciar el servidor

```bash
rails server
# o simplemente
rails s
```

La aplicación estará disponible en: **http://localhost:3000**

## 👤 Usuarios de Prueba

El seed crea varios usuarios de ejemplo:

### Administradores
- `admin@pancake.com` / `password123`
- `lucas.fernandez@pancake.com` / `123456`
- `camila.rodriguez@pancake.com` / `123456`

### Gerentes
- `gerente@pancake.com` / `password123`
- `valentina.perez@pancake.com` / `123456`

### Empleados
- `empleado@pancake.com` / `password123`
- `sofia.gomez@pancake.com` / `123456`

## 📁 Estructura del Proyecto

```
pancake-records/
├── app/
│   ├── controllers/        # Controladores
│   │   ├── backoffice/     # Panel administrativo
│   │   └── home_controller.rb  # Catálogo público
│   ├── models/             # Modelos (User, Product, Sale, etc.)
│   ├── views/              # Vistas ERB
│   │   ├── backoffice/    # Vistas del panel admin
│   │   └── home/           # Vistas del catálogo
│   ├── assets/             # CSS y JavaScript
│   └── pdfs/               # Generadores de PDF (Prawn)
├── config/
│   ├── routes.rb           # Rutas de la aplicación
│   └── database.yml        # Configuración de BD
├── db/
│   ├── migrate/            # Migraciones
│   └── seeds.rb            # Datos iniciales
└── public/                  # Archivos estáticos (favicon, etc.)
```

## 🔐 Roles y Permisos

La aplicación tiene tres roles con diferentes permisos:

- **Administrador**: Acceso completo a todas las funcionalidades
- **Gerente**: Puede gestionar productos, ventas y empleados
- **Empleado**: Puede crear ventas y ver productos

## 📊 Funcionalidades Principales

### Catálogo Público
- Búsqueda y filtrado de productos
- Visualización de detalles con imágenes y muestras de audio
- Productos relacionados

### Gestión de Productos
- CRUD completo
- Gestión de stock (incremento/decremento)
- Múltiples imágenes por producto
- Muestras de audio
- Asociación con géneros
- Eliminación lógica (soft delete)

### Gestión de Ventas
- Creación de ventas con múltiples productos
- Gestión de datos del comprador
- Cancelación de ventas (restaura stock)
- Exportación a PDF

### Reportes
- KPIs de ventas (monto total, cantidad, ticket promedio)
- Gráficos de evolución diaria
- Top productos más vendidos
- Detalle por producto
- Exportación a PDF

## 🧪 Desarrollo

### Ver emails en desarrollo

Los emails se muestran automáticamente en: **http://localhost:3000/letter_opener**

### Consola de Rails

```bash
rails console
# o
rails c
```

## 📝 Notas Adicionales

- La aplicación usa **eliminación lógica** (soft delete) para productos y usuarios
- Los archivos (imágenes, audio) se almacenan con **Active Storage**
- Los reportes usan **Chartkick** para gráficos interactivos
- Los PDFs se generan con **Prawn**
---

## Desarrolladores

* [Agustina Sol Rojas](https://github.com/agusrnfr)
* [Antonio Felix Glorioso Ceretti](https://github.com/Ationno)
* [Joaquina Saadi](https://github.com/Joaquina273)
* [Nicolás Delgado Vieira](https://github.com/Nicodelgaddo)