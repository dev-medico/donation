class Donation {
  final int? id;
  final String? date;
  final String? donationDate;
  final String? hospital;
  final String? memberId;
  final int? member;
  final String? patientAddress;
  final String? patientAge;
  final String? patientDisease;
  final String? patientName;
  final String? ownerId;

  Donation({
    this.id,
    this.date,
    this.donationDate,
    this.hospital,
    this.memberId,
    this.member,
    this.patientAddress,
    this.patientAge,
    this.patientDisease,
    this.patientName,
    this.ownerId,
  });

  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['id'],
      date: json['date'],
      donationDate: json['donation_date'],
      hospital: json['hospital'],
      memberId: json['member_id'],
      member: json['member'],
      patientAddress: json['patient_address'],
      patientAge: json['patient_age'],
      patientDisease: json['patient_disease'],
      patientName: json['patient_name'],
      ownerId: json['owner_id'],
    );
  }
}
