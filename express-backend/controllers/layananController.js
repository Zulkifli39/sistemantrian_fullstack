const db = require("../config/db");

// Admin verifikasi user
exports.verifikasiUser = (req, res) => {
  const id = req.params.id;

  db.query("UPDATE users SET is_verified = 1 WHERE id = ?", [id], (err, result) => {
    if (err) return res.status(500).send(err);
    res.json({message: "User berhasil diverifikasi"});
  });
};

// Lihat status layanan user
exports.getStatusLayanan = (req, res) => {
  const user_id = req.params.user_id;

  db.query("SELECT * FROM layanan WHERE user_id = ?", [user_id], (err, result) => {
    if (err) return res.status(500).send(err);
    res.json(result);
  });
};
