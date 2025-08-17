// routes/antrian.js
const express = require("express");
const router = express.Router();
const antrianController = require("../controllers/antrianController");

// User daftar
router.post("/daftar", antrianController.daftarAntrian);

// Admin verifikasi
router.post("/verifikasi/:id", antrianController.verifikasiAntrian); // Ubah dari PUT ke POST

// Lihat semua pendaftar
router.get("/pendaftar", antrianController.getAllPendaftar);

module.exports = router;
