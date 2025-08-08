// const express = require("express");
// const router = express.Router();
// const antrianController = require("../controllers/antrianController");

// // User ambil nomor antrian
// router.post("/ambil", antrianController.ambilNomor);

// // Admin lihat semua antrian
// router.get("/semua", antrianController.getAllAntrian);

// module.exports = router;

const express = require("express");
const router = express.Router();
const antrianController = require("../controllers/antrianController");

// User daftar
router.post("/daftar", antrianController.daftarAntrian);

// Admin verifikasi
router.put("/verifikasi/:id", antrianController.verifikasiAntrian);

// Lihat semua pendaftar
router.get("/pendaftar", antrianController.getAllPendaftar);

module.exports = router;
