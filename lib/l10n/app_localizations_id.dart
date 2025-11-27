// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Astroid Remote';

  @override
  String get connectButton => 'SAMBUNGKAN';

  @override
  String get disconnectButton => 'PUTUSKAN';

  @override
  String get remoteButton => 'KONTROL';

  @override
  String get settingsTitle => 'PENGATURAN';

  @override
  String get hapticFeedback => 'Umpan Balik Haptic';

  @override
  String get hapticFeedbackDesc => 'Rasakan sentuhan tombol';

  @override
  String get showTutorial => 'Tampilkan Tutorial';

  @override
  String get showTutorialDesc => 'Putar ulang panduan aplikasi';

  @override
  String get aboutLicenses => 'Tentang & Lisensi';

  @override
  String get aboutLicensesDesc => 'Info aplikasi dan pemberitahuan legal';

  @override
  String connectedTo(String deviceName) {
    return 'Terhubung ke: $deviceName';
  }

  @override
  String get noRobotConnected => 'Robot Tidak Terhubung';

  @override
  String get showcaseConnectTitle => 'Sambungkan ke Robot';

  @override
  String get showcaseConnectDesc =>
      'Ketuk di sini untuk memindai dan terhubung ke robot Astroid Anda melalui Bluetooth.';

  @override
  String get showcaseStatusTitle => 'Status Koneksi';

  @override
  String get showcaseStatusDesc =>
      'Ini menunjukkan apakah robot Anda terhubung. Saat terhubung, Anda dapat mengakses kontrol jarak jauh.';

  @override
  String get showcaseSettingsTitle => 'Pengaturan';

  @override
  String get showcaseSettingsDesc =>
      'Sesuaikan pengaturan aplikasi, aktifkan/nonaktifkan umpan balik haptic, atau putar ulang tutorial ini kapan saja.';

  @override
  String versionLabel(String version) {
    return 'Versi $version';
  }

  @override
  String get aboutDescription =>
      'Aplikasi kontrol jarak jauh untuk robot Astroid. Sambungkan melalui Bluetooth dan kontrol robot Anda dengan kontrol yang intuitif.';

  @override
  String get copyright => '© 2025 Asteria Academy';

  @override
  String get language => 'Bahasa';

  @override
  String get languageDesc => 'Ubah bahasa aplikasi';

  @override
  String get showcaseDisconnectTitle => 'Tombol Putuskan Koneksi';

  @override
  String get showcaseDisconnectDesc =>
      'Ketuk di sini untuk memutuskan koneksi dari robot Anda dan kembali ke layar koneksi. Anda dapat memutar ulang tutorial ini dari Pengaturan.';

  @override
  String get showcaseRemoteTitle => 'Kontrol Jarak Jauh';

  @override
  String get showcaseRemoteDesc =>
      'Ketuk di sini untuk membuka antarmuka kontrol jarak jauh dan mengontrol robot Anda. Anda dapat memutar ulang tutorial ini dari Pengaturan.';

  @override
  String get connectScreenTitle => 'Sambungkan ke Robot';

  @override
  String connectedToDevice(String deviceName) {
    return 'Terhubung ke: $deviceName';
  }

  @override
  String batteryLevel(String level) {
    return 'Baterai: $level%';
  }

  @override
  String get disconnect => 'Putuskan';

  @override
  String get robotReady => 'Robot Siap!';

  @override
  String get goBackStart => 'Kembali dan mulai petualangan Anda.';

  @override
  String get searchingRobots => 'Mencari robot Astroid...';

  @override
  String get noRobotsFound => 'Tidak Ada Robot Ditemukan';

  @override
  String get ensureRobotOn => 'Pastikan robot Anda menyala dan tekan Pindai.';

  @override
  String get scanning => 'Memindai...';

  @override
  String get scanForRobots => 'Pindai Robot';

  @override
  String successfullyConnected(String deviceName) {
    return 'Berhasil terhubung ke $deviceName';
  }

  @override
  String get connectionFailed => 'Koneksi gagal. Silakan coba lagi.';

  @override
  String get successfullyConnectedExclaim => 'Berhasil Terhubung!';

  @override
  String connectedToDeviceConnecting(String deviceName) {
    return 'Terhubung ke $deviceName';
  }

  @override
  String get connectionFailedTitle => 'Koneksi Gagal';

  @override
  String get couldNotConnect => 'Tidak dapat terhubung ke robot.';

  @override
  String get goBack => 'Kembali';

  @override
  String get connecting => 'Menghubungkan...';

  @override
  String establishingLink(String deviceName) {
    return 'Melakukan koneksi dengan $deviceName';
  }

  @override
  String get cancel => 'Batal';

  @override
  String get disconnecting => 'Memutuskan koneksi...';

  @override
  String get driveJoystick => 'Kendali';

  @override
  String get headJoystick => 'Kepala';

  @override
  String get closeGripper => 'Tutup Penjepit';

  @override
  String get openGripper => 'Buka Penjepit';

  @override
  String get expressions => 'Ekspresi';

  @override
  String get sounds => 'Suara';

  @override
  String get ledColor => 'Warna LED';

  @override
  String get modes => 'Mode';

  @override
  String get ledControl => 'Kontrol LED';

  @override
  String get tapSegment => 'Ketuk segmen';

  @override
  String get selectColor => 'Pilih warna';

  @override
  String get setAllLeds => 'Atur Semua LED';

  @override
  String get done => 'Selesai';

  @override
  String get setExpression => 'Atur Ekspresi';

  @override
  String get close => 'Tutup';

  @override
  String get playSound => 'Putar Suara';

  @override
  String get specialModes => 'Mode Khusus';

  @override
  String get lineFollower => 'Pengikut Garis';

  @override
  String get startStop => 'Mulai/Berhenti';

  @override
  String get calibrate => 'Kalibrasi';

  @override
  String get wonderPackGestures => 'Gestur Wonder Pack';

  @override
  String get gripper => 'Penjepit';

  @override
  String get sketcher => 'Sketcher';

  @override
  String get launcher => 'Peluncur';

  @override
  String get emergencyStop => 'BERHENTI';
}
