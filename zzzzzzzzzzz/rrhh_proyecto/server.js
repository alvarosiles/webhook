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
        const uniqueName = Date.now() + "_" + file.originalname.replace(/\s+/g, "_");
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
