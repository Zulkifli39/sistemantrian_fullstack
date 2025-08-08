// controllers/authController.js
const db = require("../config/db");
const bcrypt = require("bcrypt"); // kalau mau pakai hash password

// Login khusus admin
exports.loginAdmin = (req, res) => {
  const {email, password} = req.body;

  db.query("SELECT * FROM admin WHERE email = ?", [email], async (err, results) => {
    if (err) return res.status(500).json({message: "Error database", error: err});
    if (results.length === 0) return res.status(401).json({message: "Email tidak ditemukan"});

    const admin = results[0];

    // Kalau password di-hash di DB
    // const isMatch = await bcrypt.compare(password, admin.password);
    // if (!isMatch) return res.status(401).json({ message: "Password salah" });

    // Kalau password masih plain text
    if (admin.password !== password) {
      return res.status(401).json({message: "Password salah"});
    }

    res.json({
      message: "Login admin berhasil",
      admin: {
        id: admin.id,
        nama: admin.nama,
        email: admin.email,
      },
    });
  });
};
