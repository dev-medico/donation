class MonthlySponsor {
  final int? id;
  final String? name;
  final String? phone;
  final String? note;
  final String? createdAt;
  final int? donationCount;
  final int? totalAmount;
  final List<MonthlySponsorDonation>? donations;

  MonthlySponsor({
    this.id,
    this.name,
    this.phone,
    this.note,
    this.createdAt,
    this.donationCount,
    this.totalAmount,
    this.donations,
  });

  factory MonthlySponsor.fromJson(Map<String, dynamic> json) {
    List<MonthlySponsorDonation>? dons;
    if (json['donations'] != null) {
      dons = (json['donations'] as List)
          .map((e) => MonthlySponsorDonation.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return MonthlySponsor(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      note: json['note'] as String?,
      createdAt: json['created_at'] as String?,
      donationCount: (json['donation_count'] as num?)?.toInt(),
      totalAmount: (json['total_amount'] as num?)?.toInt(),
      donations: dons,
    );
  }
}

class MonthlySponsorDonation {
  final int? id;
  final int? sponsorId;
  final int? amount;
  final String? date;
  final String? note;

  MonthlySponsorDonation({
    this.id,
    this.sponsorId,
    this.amount,
    this.date,
    this.note,
  });

  factory MonthlySponsorDonation.fromJson(Map<String, dynamic> json) {
    return MonthlySponsorDonation(
      id: (json['id'] as num?)?.toInt(),
      sponsorId: (json['sponsor_id'] as num?)?.toInt(),
      amount: (json['amount'] as num?)?.toInt(),
      date: json['date'] as String?,
      note: json['note'] as String?,
    );
  }
}
