// models/Antrian.js
const db = require("../config/db");

// Ambil semua data antrian
exports.getAll = (callback) => {
  db.query("SELECT * FROM antrian ORDER BY created_at DESC", callback);
};

// Tambah pendaftar antrian baru
exports.create = (nama, nik, jenis_layanan, callback) => {
  db.query(
    "INSERT INTO antrian (nama, nik, jenis_layanan, status_layanan) VALUES (?, ?, ?, 'Belum Diverifikasi')",
    [nama, nik, jenis_layanan],
    callback
  );
};

// Verifikasi antrian dan beri nomor
exports.verifikasi = (id, nomor_antrian, status_layanan, callback) => {
  db.query(
    "UPDATE antrian SET nomor_antrian = ?, status_layanan = ? WHERE id = ?",
    [nomor_antrian, status_layanan, id],
    callback
  );
};

// Ambil antrian berdasarkan NIK
exports.getByNik = (nik, callback) => {
  db.query("SELECT * FROM antrian WHERE nik = ?", [nik], callback);
};
