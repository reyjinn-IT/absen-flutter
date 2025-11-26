class Kelas {
  final int id;
  final String kodeKelas;
  final String namaKelas;
  final String matakuliah;
  final String dosen;

  Kelas({
    required this.id,
    required this.kodeKelas,
    required this.namaKelas,
    required this.matakuliah,
    required this.dosen,
  });

  factory Kelas.fromJson(Map<String, dynamic> json) {
    return Kelas(
      id: json['id'],
      kodeKelas: json['kode_kelas'],
      namaKelas: json['nama_kelas'],
      matakuliah: json['matakuliah']?['nama_mk'] ?? 'Unknown',
      dosen: json['dosen']?['name'] ?? 'Unknown',
    );
  }
}