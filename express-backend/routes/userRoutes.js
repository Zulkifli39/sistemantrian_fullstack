const express = require("express");
const router = express.Router();
const userController = require("../controllers/userController");

router.post("/daftar", userController.daftarUser);

module.exports = router;
