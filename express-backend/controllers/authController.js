// controllers/authController.js
const db = require("../config/db");

// Login khusus admin
exports.loginAdmin = (req, res) => {
  const {email, password} = req.body;

  db.query("SELECT * FROM admin WHERE email = ?", [email], (err, results) => {
    if (err) return res.status(500).json({message: "Error database", error: err});
    if (results.length === 0) return res.status(401).json({message: "Email tidak ditemukan"});

    const admin = results[0];

    // Cek password (plain text sementara)
    if (admin.password !== password) {
      return res.status(401).json({message: "Password salah"});
    }

    // ✅ Kirim role supaya bisa dibaca di Flutter
    res.json({
      message: "Login admin berhasil",
      admin: {
        id: admin.id,
        nama: admin.nama,
        email: admin.email,
        role: "admin",
      },
    });
  });
};
