const db = require("../config/db");

// Daftar user untuk antrian
exports.daftarUser = (req, res) => {
  const {nama, nik, jenis_layanan} = req.body;

  if (!nama || !nik || !jenis_layanan) {
    return res.status(400).json({message: "Semua field harus diisi"});
  }

  const sql = "INSERT INTO users (nama, nik, jenis_layanan) VALUES (?, ?, ?)";
  db.query(sql, [nama, nik, jenis_layanan], (err, result) => {
    if (err) {
      console.error("❌ Gagal daftar user:", err);
      return res.status(500).json({message: "Gagal mendaftar", error: err});
    }

    res.status(201).json({
      success: true,
      message: "Pendaftaran berhasil, menunggu verifikasi admin",
      data: {id: result.insertId},
    });
  });
};
