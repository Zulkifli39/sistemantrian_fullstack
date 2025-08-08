// User daftar antrian
exports.daftarAntrian = async (req, res) => {
  try {
    const {nama, nik, jenis_layanan} = req.body;

    if (!nama || !nik || !jenis_layanan) {
      return res.status(400).json({message: "Semua field harus diisi"});
    }

    // Cek jika NIK sudah ada
    const existing = await Antrian.findOne({where: {nik}});
    if (existing) {
      return res.status(400).json({message: "NIK sudah terdaftar, tunggu verifikasi admin"});
    }

    const pendaftar = await Antrian.create({
      nama,
      nik,
      jenis_layanan,
    });

    res.status(201).json({
      success: true,
      message: "Pendaftaran berhasil, menunggu verifikasi admin",
      data: pendaftar,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({success: false, message: "Terjadi kesalahan server"});
  }
};
