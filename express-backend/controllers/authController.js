const db = require("../config/db");

// Login khusus admin
exports.loginAdmin = async (req, res) => {
  try {
    const {email, password} = req.body;

    if (!email || !password) {
      return res.status(400).json({success: false, message: "Email dan password wajib diisi"});
    }

    const [results] = await db.query("SELECT * FROM admin WHERE email = ?", [email]);

    if (results.length === 0) {
      return res.status(401).json({success: false, message: "Email tidak ditemukan"});
    }

    const admin = results[0];

    // Cek password (plain text sementara)
    if (admin.password !== password) {
      return res.status(401).json({success: false, message: "Password salah"});
    }

    // ✅ Kirim role supaya bisa dibaca di Flutter
    res.json({
      success: true,
      message: "Login admin berhasil",
      admin: {
        id: admin.id,
        nama: admin.nama,
        email: admin.email,
        role: "admin",
      },
    });
  } catch (error) {
    console.error("Error in loginAdmin:", error);
    res.status(500).json({success: false, message: `Gagal login: ${error.message}`});
  }
};
