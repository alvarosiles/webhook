#!/bin/bash

echo "🚀 Verificando proyecto RRHH..."

# -------------------------------------------
# Verificar Node
# -------------------------------------------
if ! command -v node &> /dev/null
then
    echo "❌ Node.js no está instalado."
    echo "Instálalo desde https://nodejs.org"
    exit 1
fi

# -------------------------------------------
# Si no existe carpeta, crearla
# -------------------------------------------
if [ ! -d "rrhh_proyecto" ]; then
    echo "📦 Proyecto no encontrado. Creando..."
    mkdir rrhh_proyecto
fi

cd rrhh_proyecto

# -------------------------------------------
# Inicializar npm si no existe
# -------------------------------------------
if [ ! -f package.json ]; then
    echo "📦 Inicializando npm..."
    npm init -y
    npm install express cors multer
fi

# -------------------------------------------
# Agregar script start si no existe
# -------------------------------------------
node -e "
const fs = require('fs');
const pkg = JSON.parse(fs.readFileSync('package.json'));
pkg.scripts = pkg.scripts || {};
if(!pkg.scripts.start){
  pkg.scripts.start = 'node server.js';
  fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));
}
"

# -------------------------------------------
# Crear rrhh.json si no existe
# -------------------------------------------
if [ ! -f rrhh.json ]; then
    echo "[]" > rrhh.json
fi

# -------------------------------------------
# Crear carpeta uploads si no existe
# -------------------------------------------
if [ ! -d uploads ]; then
    mkdir uploads
fi

# -------------------------------------------
# Crear server.js si no existe
# -------------------------------------------
if [ ! -f server.js ]; then
cat <<EOL > server.js
const express = require("express");
const fs = require("fs");
const cors = require("cors");
const multer = require("multer");

const app = express();
const PORT = 3000;

app.use(express.json());
app.use(cors());
app.use(express.static("."));
app.use("/uploads", express.static("uploads"));

// Configuración multer
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, "uploads/");
    },
    filename: (req, file, cb) => {
        const uniqueName = Date.now() + "_" + file.originalname.replace(/\\s+/g, "_");
        cb(null, uniqueName);
    }
});

const upload = multer({ storage });

// GET
app.get("/rrhh", (req, res) => {
    try {
        const data = fs.readFileSync("./rrhh.json", "utf8");
        res.json(JSON.parse(data));
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// POST con foto
app.post("/rrhh", upload.single("foto"), (req, res) => {
    try {
        let data = [];
        if (fs.existsSync("./rrhh.json")) {
            data = JSON.parse(fs.readFileSync("./rrhh.json", "utf8"));
        }

        const nuevo = {
            nombre: req.body.nombre,
            apellido: req.body.apellido,
            edad: Number(req.body.edad),
            foto: req.file ? req.file.filename : null
        };

        data.push(nuevo);
        fs.writeFileSync("./rrhh.json", JSON.stringify(data, null, 4));

        res.json({ result: "success" });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.listen(PORT, () => {
    console.log("=====================================");
    console.log("🚀 Servidor corriendo en:");
    console.log("👉 server  http://localhost:3000/rrhh");
    console.log("👉 web http://localhost:3000/rrhh.html");
    console.log("=====================================");
});
EOL
fi

# -------------------------------------------
# Crear rrhh.html si no existe
# -------------------------------------------
if [ ! -f rrhh.html ]; then
cat <<EOL > rrhh.html
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<title>RRHH con Fotos</title>
<style>
body { font-family: Arial; margin: 40px; }
input { margin: 5px; padding: 5px; }
button { padding: 6px 10px; margin: 5px 0; cursor: pointer; }
table { margin-top: 20px; border-collapse: collapse; width: 80%; }
table, th, td { border: 1px solid #ccc; }
th, td { padding: 8px; text-align: center; }
img { border-radius: 6px; }
</style>
</head>
<body>

<h2>RRHH - Registro con Foto</h2>

<form id="formulario" enctype="multipart/form-data">
<input type="text" name="nombre" placeholder="Nombre" required>
<input type="text" name="apellido" placeholder="Apellido" required>
<input type="number" name="edad" placeholder="Edad" required>
<input type="file" name="foto" accept="image/*">
<button type="submit">Guardar</button>
</form>

<h3>Lista</h3>

<table>
<thead>
<tr>
<th>Nombre</th>
<th>Apellido</th>
<th>Edad</th>
<th>Foto</th>
</tr>
</thead>
<tbody id="tabla"></tbody>
</table>

<script>
function cargarJSON() {
  fetch("/rrhh")
    .then(res => res.json())
    .then(data => mostrar(data));
}

function mostrar(personas) {
  const tabla = document.getElementById("tabla");
  tabla.innerHTML = "";

  personas.forEach(p => {
    tabla.innerHTML += \`
      <tr>
        <td>\${p.nombre}</td>
        <td>\${p.apellido}</td>
        <td>\${p.edad}</td>
        <td>
          \${p.foto ? '<img src="/uploads/' + p.foto + '" width="70">' : "Sin foto"}
        </td>
      </tr>
    \`;
  });
}

document.getElementById("formulario")
.addEventListener("submit", function(e) {
  e.preventDefault();
  const formData = new FormData(this);

  fetch("/rrhh", {
    method: "POST",
    body: formData
  })
  .then(res => res.json())
  .then(() => {
    this.reset();
    cargarJSON();
  });
});

cargarJSON();
</script>

</body>
</html>
EOL
fi

echo "====================================="
echo "🚀 Iniciando servidor..."
echo "====================================="

npm start
