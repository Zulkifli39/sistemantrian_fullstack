import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class AntrianProvider with ChangeNotifier {
  // ====== DATA STATE ======
  List<dynamic> _pendaftar = [];
  List<dynamic> _antrian = [];
  int _nowServingIndex = 0;

  final FlutterTts _flutterTts = FlutterTts();
  IO.Socket? socket; // WebSocket client

  // ====== GETTER ======
  List<dynamic> get pendaftar => _pendaftar;
  List<dynamic> get antrian => _antrian;
  int get nowServingIndex => _nowServingIndex;

  Map<String, dynamic>? get nowServing =>
      _antrian.isNotEmpty ? _antrian[_nowServingIndex] : null;

  // ====== CONSTRUCTOR ======
  AntrianProvider() {
    _initTts();
    _initSocket(); // <-- Socket otomatis jalan
  }

  // ====== INIT SOCKET ======
  void _initSocket() {
    socket = IO.io(
      "http://10.0.2.2:3000", // Android Emulator → ganti pakai IP laptop jika di device asli
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket!.connect();

    socket!.onConnect((_) {
      debugPrint("✅ Socket connected: ${socket!.id}");
    });

    socket!.onDisconnect((_) {
      debugPrint("❌ Socket disconnected");
    });

    // Saat ada update antrian dari server
    socket!.on("updateAntrian", (data) {
      debugPrint("📥 updateAntrian dari server: $data");
      if (data is List) {
        _antrian = data;
      } else if (data is Map) {
        _antrian.add(data);
      }
      notifyListeners();
    });
  }

  // Emit event ke server
  void emitNext() {
    if (nowServing != null) {
      socket?.emit("nextAntrian", nowServing);
      debugPrint("📤 Emit nextAntrian: $nowServing");
    }
  }

  // ====== INIT TTS ======
  Future<void> _initTts() async {
    await _flutterTts.setLanguage("id-ID"); // Bahasa Indonesia
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.9); // sedikit lebih lambat
    await _flutterTts.awaitSpeakCompletion(false);

    // Debug logging
    _flutterTts.setStartHandler(() {
      debugPrint("🔊 TTS mulai berbicara");
    });
    _flutterTts.setCompletionHandler(() {
      debugPrint("✅ TTS selesai");
    });
    _flutterTts.setErrorHandler((msg) {
      debugPrint("❌ TTS Error: $msg");
    });
  }

  Future<void> _speak(String text) async {
    try {
      await _flutterTts.stop(); // hentikan suara sebelumnya
      await Future.delayed(const Duration(milliseconds: 200));

      if (text.isNotEmpty) {
        debugPrint("➡️ Speak: $text");
        await _flutterTts.speak(text);
      }
    } catch (e) {
      debugPrint("⚠️ TTS Exception: $e");
    }
  }

  // ====== CRUD PENDAFTAR & ANTRIAN ======

  void setPendaftar(List<dynamic> data) {
    _pendaftar = data;
    notifyListeners();
  }

  void setAntrian(List<dynamic> data) {
    _antrian = data;
    if (_nowServingIndex >= _antrian.length) {
      _nowServingIndex = _antrian.isNotEmpty ? _antrian.length - 1 : 0;
    }
    notifyListeners();
  }

  void updatePendaftarAfterVerification(int userId, Map<String, dynamic> data) {
    final index = _pendaftar.indexWhere((user) => user["user_id"] == userId);

    if (index != -1) {
      _pendaftar[index]["status"] = data["status"];
      _pendaftar[index]["nomor_antrian"] = data["nomor_antrian"];
      _pendaftar[index]["status_layanan"] = data["status_layanan"];
      notifyListeners();
    }

    if (!_antrian.any((item) => item["user_id"] == userId)) {
      final newAntrianId = data["id"] ?? DateTime.now().millisecondsSinceEpoch;
      _antrian.add({
        "id": newAntrianId,
        "user_id": userId,
        "nomor_antrian": data["nomor_antrian"],
        "nama": index != -1 ? _pendaftar[index]["nama"] : "Unknown",
        "status_layanan": data["status_layanan"],
        "created_at": DateTime.now().toIso8601String(),
      });
      notifyListeners();
    }
  }

  void updateAntrianStatus(String id, String newStatus) {
    final indexAntrian =
        _antrian.indexWhere((item) => item["id"].toString() == id);

    if (indexAntrian != -1) {
      final userId = _antrian[indexAntrian]["user_id"];
      _antrian[indexAntrian]["status_layanan"] = newStatus;

      final indexPendaftar =
          _pendaftar.indexWhere((user) => user["user_id"] == userId);

      if (indexPendaftar != -1) {
        _pendaftar[indexPendaftar]["status_layanan"] = newStatus;
      }
      notifyListeners();
    }
  }

  void deleteAntrian(String id) {
    final indexAntrian =
        _antrian.indexWhere((item) => item["id"].toString() == id);

    if (indexAntrian != -1) {
      final userId = _antrian[indexAntrian]["user_id"];
      _antrian.removeWhere((item) => item["id"].toString() == id);

      final indexPendaftar =
          _pendaftar.indexWhere((user) => user["user_id"] == userId);

      if (indexPendaftar != -1) {
        _pendaftar.removeAt(indexPendaftar);
      }
      notifyListeners();
    }
  }

  // ====== NEXT / PREVIOUS / ULANG ======

  void callNext() {
    if (_antrian.isNotEmpty && _nowServingIndex < _antrian.length - 1) {
      _nowServingIndex++;
      final nomor = _antrian[_nowServingIndex]["nomor_antrian"];
      final nama = _antrian[_nowServingIndex]["nama"];
      final text =
          "Nomor antrian $nomor, atas nama $nama, silakan menuju loket.";
      debugPrint("➡️ Next: $text");
      _speak(text);

      emitNext(); // kirim ke server biar broadcast ke semua client
      notifyListeners();
    }
  }

  void callPrevious() {
    if (_antrian.isNotEmpty && _nowServingIndex > 0) {
      _nowServingIndex--;
      final nomor = _antrian[_nowServingIndex]["nomor_antrian"];
      final nama = _antrian[_nowServingIndex]["nama"];
      final text = "Kembali ke nomor antrian $nomor, atas nama $nama.";
      debugPrint("⬅️ Prev: $text");
      _speak(text);
      notifyListeners();
    }
  }

  void panggilUlang() {
    if (_antrian.isNotEmpty) {
      final nomor = _antrian[_nowServingIndex]["nomor_antrian"];
      final nama = _antrian[_nowServingIndex]["nama"];
      final text =
          "Panggilan ulang, nomor antrian $nomor, atas nama $nama, silakan menuju loket.";
      debugPrint("🔁 Ulang: $text");
      _speak(text);
    }
  }

  void setNowServing(int index) {
    if (index >= 0 && index < _antrian.length) {
      _nowServingIndex = index;
      final nomor = _antrian[_nowServingIndex]["nomor_antrian"];
      final nama = _antrian[_nowServingIndex]["nama"];
      final text =
          "Nomor antrian $nomor, atas nama $nama, silakan menuju loket.";
      debugPrint("🎯 SetNowServing: $text");
      _speak(text);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    socket?.disconnect();
    socket?.dispose();
    super.dispose();
  }
}
