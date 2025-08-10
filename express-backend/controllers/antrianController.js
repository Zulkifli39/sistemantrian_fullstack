const db = require("../config/db");

// User daftar antrian → insert ke tabel users
exports.daftarAntrian = async (req, res) => {
  try {
    const {nama, nik, jenis_layanan} = req.body;

    if (!nama || !nik || !jenis_layanan) {
      return res.status(400).json({success: false, message: "Semua field wajib diisi"});
    }

    // Simpan user baru
    const [userResult] = await db.query("INSERT INTO users (nama, nik, jenis_layanan) VALUES (?, ?, ?)", [
      nama,
      nik,
      jenis_layanan,
    ]);

    res.status(201).json({
      success: true,
      message: "Pendaftaran berhasil, menunggu verifikasi admin",
      data: {
        user_id: userResult.insertId,
        nama,
        nik,
        jenis_layanan,
      },
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({success: false, message: "Terjadi kesalahan server"});
  }
};

// Admin verifikasi → insert ke tabel antrian
exports.verifikasiAntrian = async (req, res) => {
  try {
    const {id} = req.params; // id pendaftar

    // Cari nomor antrian terakhir
    const [rows] = await db.query("SELECT MAX(nomor_antrian) AS lastNumber FROM antrian");
    const lastNumber = rows[0].lastNumber || 0;
    const newNumber = lastNumber + 1;

    // Update status & nomor antrian
    await db.query("UPDATE antrian SET nomor_antrian = ?, status_layanan = ? WHERE id = ?", [
      newNumber,
      "Menunggu",
      id,
    ]);

    res.json({
      success: true,
      message: "Verifikasi berhasil",
      nomor_antrian: newNumber,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({message: "Terjadi kesalahan server"});
  }
};

// Lihat semua pendaftar (gabungan users + antrian)
exports.getAllPendaftar = async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT users.id AS user_id, users.nama, users.nik, users.jenis_layanan,
             antrian.nomor_antrian, antrian.status_layanan
      FROM users
      LEFT JOIN antrian ON users.id = antrian.user_id
      ORDER BY users.created_at ASC
    `);
    res.json({success: true, data: rows});
  } catch (error) {
    console.error(error);
    res.status(500).json({success: false, message: "Gagal mengambil data"});
  }
};
