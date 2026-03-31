const express = require("express");
const fs = require("fs");
const cors = require("cors");
const app = express();
const PORT = 3000;

// Middleware JSON
app.use(express.json());

// Habilitar CORS
app.use(cors());

// Servir HTML y JS
app.use(express.static("."));

// GET rrhh.json
app.get("/rrhh", (req, res) => {
    try {
        const data = fs.readFileSync("./rrhh.json", "utf8");
        res.json(JSON.parse(data));
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// POST rrhh.json
app.post("/rrhh", (req, res) => {
    try {
        fs.writeFileSync("./rrhh.json", JSON.stringify(req.body, null, 4));
        res.json({ result: "success" });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.listen(PORT, () => console.log(`Servidor corriendo en http://localhost:${PORT}`));
