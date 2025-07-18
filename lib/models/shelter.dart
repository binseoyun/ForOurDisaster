class Shelter {
  final String name;            // 시설명 (REARE_NM)
  final String address;         // 도로명전체주소 (RONA_DADDR)
  final double latitude;        // 위도 (LAT)
  final double longitude;       // 경도 (LOT)
  final String shelterTypeCode; // 대피소구분코드 (SHLT_SE_CD)
  final String shelterTypeName; // 대피소구분명 (SHLT_SE_NM)
  final String managementId;    // 관리일련번호 (MNG_SN)

  Shelter({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.shelterTypeCode,
    required this.shelterTypeName,
    required this.managementId,
  });

  factory Shelter.fromJson(Map<String, dynamic> json) {
    return Shelter(
      name: json['REARE_NM'] ?? '',
      address: json['RONA_DADDR'] ?? '',
      latitude: double.tryParse(json['LAT'].toString()) ?? 0.0,
      longitude: double.tryParse(json['LOT'].toString()) ?? 0.0,
      shelterTypeCode: json['SHLT_SE_CD'] ?? '',
      shelterTypeName: json['SHLT_SE_NM'] ?? '',
      managementId: json['MNG_SN'] ?? '',
    );
  }
}
