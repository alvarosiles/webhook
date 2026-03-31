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
# Si ya existe el proyecto
# -------------------------------------------
if [ -f "rrhh_proyecto/package.json" ]; then
    echo "====================================="
    echo "✅ Proyecto ya existe."
    echo "🚀 Iniciando servidor..."
    echo "====================================="
    
    cd rrhh_proyecto
    npm start
    exit 0
fi

# -------------------------------------------
# Si NO existe, crear proyecto
# -------------------------------------------
echo "📦 Proyecto no encontrado. Creando..."

mkdir rrhh_proyecto
cd rrhh_proyecto

npm init -y
npm install express cors

# Agregar script start
node -e "
const fs = require('fs');
const pkg = JSON.parse(fs.readFileSync('package.json'));
pkg.scripts.start = 'node server.js';
fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));
"

echo "[]" > rrhh.json

# Crear server.js
cat <<EOL > server.js
const express = require("express");
const fs = require("fs");
const cors = require("cors");

const app = express();
const PORT = 3000;

app.use(express.json());
app.use(cors());
app.use(express.static("."));

app.get("/rrhh", (req, res) => {
    try {
        const data = fs.readFileSync("./rrhh.json", "utf8");
        res.json(JSON.parse(data));
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

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

# Crear rrhh.html
cat <<EOL > rrhh.html
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<title>RRHH</title>
</head>
<body>
<h2>RRHH Sistema</h2>
<p>Proyecto creado correctamente.</p>
<a href="/rrhh.html">Abrir sistema</a>
</body>
</html>
EOL

echo "====================================="
echo "✅ Proyecto creado correctamente."
echo "🚀 Iniciando servidor..."
echo "====================================="

npm start
