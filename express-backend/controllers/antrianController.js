// controllers/antrianController.js
const db = require("../config/db");

// User daftar antrian → insert ke tabel users
exports.daftarAntrian = async (req, res) => {
  try {
    const {nama, nik, jenis_layanan} = req.body;

    if (!nama || !nik || !jenis_layanan) {
      return res.status(400).json({success: false, message: "Semua field wajib diisi"});
    }

    const [userResult] = await db.query("INSERT INTO users (nama, nik, jenis_layanan, status) VALUES (?, ?, ?, ?)", [
      nama,
      nik,
      jenis_layanan,
      "Menunggu Verifikasi",
    ]);

    res.status(201).json({
      success: true,
      message: "Pendaftaran berhasil, menunggu verifikasi admin",
      data: {
        user_id: userResult.insertId,
        nama,
        nik,
        jenis_layanan,
        status: "Menunggu Verifikasi",
      },
    });
  } catch (error) {
    console.error("Error in daftarAntrian:", error);
    res.status(500).json({success: false, message: `Terjadi kesalahan server: ${error.message}`});
  }
};

// Admin verifikasi → insert ke tabel antrian
exports.verifikasiAntrian = async (req, res) => {
  try {
    const {id} = req.params;

    const [existingAntrian] = await db.query("SELECT * FROM antrian WHERE user_id = ?", [id]);
    if (existingAntrian.length > 0) {
      return res.status(400).json({success: false, message: "User sudah diverifikasi"});
    }

    const [rows] = await db.query("SELECT MAX(nomor_antrian) AS lastNumber FROM antrian");
    const lastNumber = rows[0].lastNumber || 0;
    const newNumber = lastNumber + 1;

    await db.query("INSERT INTO antrian (user_id, nomor_antrian, status_layanan) VALUES (?, ?, ?)", [
      id,
      newNumber,
      "Menunggu",
    ]);

    await db.query("UPDATE users SET status = ? WHERE id = ?", ["Terverifikasi", id]);

    res.json({
      success: true,
      message: "Verifikasi berhasil",
      nomor_antrian: newNumber,
    });
  } catch (error) {
    console.error("Error in verifikasiAntrian:", error);
    res.status(500).json({success: false, message: `Terjadi kesalahan server: ${error.message}`});
  }
};

// Lihat semua pendaftar (gabungan users + antrian)
exports.getAllPendaftar = async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT users.id AS user_id, users.nama, users.nik, users.jenis_layanan, users.status,
             antrian.nomor_antrian, antrian.status_layanan
      FROM users
      LEFT JOIN antrian ON users.id = antrian.user_id
      ORDER BY users.created_at ASC
    `);
    res.json({success: true, data: rows});
  } catch (error) {
    console.error("Error in getAllPendaftar:", error);
    res.status(500).json({success: false, message: `Gagal mengambil data: ${error.message}`});
  }
};
