const db = require("../config/db");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");

exports.login = (req, res) => {
  const {email, password} = req.body;

  db.query("SELECT * FROM admin WHERE email = ?", [email], async (err, results) => {
    if (err) return res.status(500).json({message: "Database error", error: err});

    if (results.length === 0) {
      return res.status(401).json({message: "Email tidak ditemukan"});
    }

    const admin = results[0];
    const isMatch = await bcrypt.compare(password, admin.password);

    if (!isMatch) {
      return res.status(401).json({message: "Password salah"});
    }

    // Buat token JWT
    const token = jwt.sign({id: admin.id, role: "admin"}, process.env.JWT_SECRET || "secret", {
      expiresIn: "1d",
    });

    res.json({
      message: "Login berhasil",
      role: "admin", // ✅ role langsung dikirim
      token,
      admin: {
        id: admin.id,
        nama: admin.nama,
        email: admin.email,
      },
    });
  });
};
