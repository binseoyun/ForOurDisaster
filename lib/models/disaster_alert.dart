class DisasterAlert {
  final int sn; // 일련번호
  final String crtDt; // 생성일시
  final String msgCn; // 메시지내용
  final String rcptnRgnNm; // 수신지역명
  final String emrgStepNm; // 긴급단계명
  final String dstSeNm; // 재해구분명
  final String regYmd; // 등록일자
  final String mdfcnYmd; // 수정일자

  DisasterAlert({
    required this.sn,
    required this.crtDt,
    required this.msgCn,
    required this.rcptnRgnNm,
    required this.emrgStepNm,
    required this.dstSeNm,
    required this.regYmd,
    required this.mdfcnYmd,
  });

  factory DisasterAlert.fromJson(Map<String, dynamic> json) {
    return DisasterAlert(
      sn: int.parse(json['SN'].toString()),
      crtDt: json['CRT_DT'] ?? '',
      msgCn: json['MSG_CN'] ?? '',
      rcptnRgnNm: json['RCPTN_RGN_NM'] ?? '',
      emrgStepNm: json['EMRG_STEP_NM'] ?? '',
      dstSeNm: json['DST_SE_NM'] ?? '',
      regYmd: json['REG_YMD'] ?? '',
      mdfcnYmd: json['MDFCN_YMD'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'SN': sn, 
      'CRT_DT': crtDt,
      'MSG_CN': msgCn,
      'RCPTN_RGN_NM': rcptnRgnNm,
      'EMRG_STEP_NM': emrgStepNm,
      'DST_SE_NM': dstSeNm,
      'REG_YMD': regYmd,
      'MDFCN_YMD': mdfcnYmd,
    };
  }
}
