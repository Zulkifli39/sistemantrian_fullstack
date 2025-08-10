// controllers/authController.js
const db = require("../config/db");

exports.loginAdmin = (req, res) => {
  const {email, password} = req.body;

  db.query("SELECT * FROM admin WHERE email = ?", [email], async (err, results) => {
    if (err) return res.status(500).json({success: false, message: "Error database", error: err});
    if (results.length === 0) return res.status(401).json({success: false, message: "Email tidak ditemukan"});

    const admin = results[0];

    // Password masih plain text
    if (admin.password !== password) {
      return res.status(401).json({success: false, message: "Password salah"});
    }

    res.json({
      success: true,
      message: "Login admin berhasil",
      user: {
        // <-- pakai 'user' biar cocok dengan Flutter
        id: admin.id,
        nama: admin.nama,
        email: admin.email,
        role: "admin", // <-- penting untuk validasi di Flutter
      },
    });
  });
};
