#!/bin/bash

echo "🚀 Iniciando configuración del proyecto RRHH..."

# -------------------------------------------
# Verificar Node.js
# -------------------------------------------
if ! command -v node &> /dev/null
then
    echo "❌ Node.js no está instalado."
    echo "Instálalo desde https://nodejs.org y vuelve a ejecutar este script."
    exit 1
else
    echo "✅ Node.js detectado: $(node -v)"
fi

# -------------------------------------------
# Crear carpeta
# -------------------------------------------
mkdir -p rrhh_proyecto
cd rrhh_proyecto

# -------------------------------------------
# Inicializar npm
# -------------------------------------------
if [ ! -f package.json ]; then
    echo "📦 Inicializando npm..."
    npm init -y
fi

# -------------------------------------------
# Instalar dependencias
# -------------------------------------------
echo "📥 Instalando dependencias..."
npm install express cors

# -------------------------------------------
# Agregar script start
# -------------------------------------------
node -e "
const fs = require('fs');
const pkg = JSON.parse(fs.readFileSync('package.json'));
pkg.scripts = pkg.scripts || {};
pkg.scripts.start = 'node server.js';
fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));
"

# -------------------------------------------
# Crear rrhh.json
# -------------------------------------------
if [ ! -f rrhh.json ]; then
    echo "[]" > rrhh.json
fi

# -------------------------------------------
# Crear server.js
# -------------------------------------------
cat <<EOL > server.js
const express = require("express");
const fs = require("fs");
const cors = require("cors");

const app = express();
const PORT = 3000;

app.use(express.json());
app.use(cors());
app.use(express.static("."));

// GET
app.get("/rrhh", (req, res) => {
    try {
        const data = fs.readFileSync("./rrhh.json", "utf8");
        res.json(JSON.parse(data));
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// POST
app.post("/rrhh", (req, res) => {
    try {
        fs.writeFileSync("./rrhh.json", JSON.stringify(req.body, null, 4));
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

# -------------------------------------------
# Crear rrhh.html
# -------------------------------------------
cat <<EOL > rrhh.html
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<title>RRHH con Backend</title>
<style>
body { font-family: Arial; margin: 40px; }
input { margin: 5px; padding: 5px; }
button { padding: 6px 10px; margin: 5px 0; cursor: pointer; }
table { margin-top: 20px; border-collapse: collapse; width: 60%; }
table, th, td { border: 1px solid #ccc; }
th, td { padding: 8px; text-align: center; }
pre { background: #1e1e1e; color: #00ff88; padding: 15px; margin-top: 20px; }
</style>
</head>
<body>

<h2>RRHH - Registro</h2>

<input type="text" id="nombre" placeholder="Nombre">
<input type="text" id="apellido" placeholder="Apellido">
<input type="number" id="edad" placeholder="Edad">
<button onclick="guardarRegistro()">Guardar</button>

<h3>Lista</h3>
<table>
<thead>
<tr>
<th>Nombre</th>
<th>Apellido</th>
<th>Edad</th>
</tr>
</thead>
<tbody id="tabla"></tbody>
</table>

<h3>JSON Actual</h3>
<pre id="jsonOutput"></pre>

<script>
let personas = [];

function cargarJSON() {
  fetch("/rrhh")
    .then(res => res.json())
    .then(data => { personas = data; mostrar(); })
    .catch(err => console.log("Error:", err));
}

function mostrar() {
  const tabla = document.getElementById("tabla");
  tabla.innerHTML = "";
  personas.forEach(p => {
    tabla.innerHTML += \`
      <tr>
        <td>\${p.nombre}</td>
        <td>\${p.apellido}</td>
        <td>\${p.edad}</td>
      </tr>
    \`;
  });
  document.getElementById("jsonOutput").textContent =
    JSON.stringify(personas, null, 4);
}

function guardarRegistro() {
  const nombre = document.getElementById("nombre").value;
  const apellido = document.getElementById("apellido").value;
  const edad = document.getElementById("edad").value;

  if (!nombre || !apellido || !edad) {
    alert("Todos los campos son obligatorios");
    return;
  }

  personas.push({ nombre, apellido, edad: Number(edad) });

  fetch("/rrhh", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(personas)
  })
  .then(res => res.json())
  .then(() => { limpiar(); mostrar(); })
  .catch(err => console.log("Error:", err));
}

function limpiar() {
  document.getElementById("nombre").value = "";
  document.getElementById("apellido").value = "";
  document.getElementById("edad").value = "";
}

cargarJSON();
</script>

</body>
</html>
EOL

echo ""
echo "✅ Proyecto RRHH listo en: $(pwd)"
echo ""

read -p "¿Deseas iniciar el servidor ahora? (s/n): " respuesta

if [[ "$respuesta" == "s" || "$respuesta" == "S" ]]; then
    npm start
else
    echo "👉 Para iniciar manualmente:"
    echo "cd rrhh_proyecto"
    echo "npm start"
fi
