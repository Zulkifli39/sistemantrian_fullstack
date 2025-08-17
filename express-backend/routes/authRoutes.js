const express = require("express");
const router = express.Router();
const authController = require("../controllers/authController");

// Login khusus admin
router.post("/login", authController.loginAdmin);

module.exports = router;
