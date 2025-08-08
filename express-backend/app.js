const express = require("express");
const cors = require("cors");
require("dotenv").config();

const authRoutes = require("./routes/authRoutes");
const antrianRoutes = require("./routes/antrianRoutes");
const layananRoutes = require("./routes/layananRoutes");

const app = express();

// Middleware
app.use(cors());
app.use(express.json()); // Gantikan bodyParser.json()
app.use(express.urlencoded({extended: true})); // Untuk data dari form (optional)

// Routes
app.use("/api/auth", authRoutes);
app.use("/api/antrian", antrianRoutes);
app.use("/api/layanan", layananRoutes);

// Server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Server jalan di http://localhost:${PORT}`);
});
