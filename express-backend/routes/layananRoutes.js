const express = require("express");
const router = express.Router();
const layananController = require("../controllers/layananController");

// Verifikasi user oleh admin
router.put("/verifikasi/:id", layananController.verifikasiUser);

// Lihat status layanan user
router.get("/status/:user_id", layananController.getStatusLayanan);

module.exports = router;
