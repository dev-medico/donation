import 'package:json_annotation/json_annotation.dart';
import 'package:donation/src/features/donation/models/donation.dart';

part 'patient.g.dart';

@JsonSerializable()
class Patient {
  final int? id;
  final String? name;
  final String? phone;
  final String? address;
  final String? township;
  final String? ward;
  final String? village;
  final String? age;
  @JsonKey(name: 'birth_date')
  final String? birthDate;
  final String? gender;
  @JsonKey(name: 'blood_type')
  final String? bloodType;
  @JsonKey(name: 'medical_notes')
  final String? medicalNotes;
  @JsonKey(name: 'donation_count')
  final int? donationCount;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(includeFromJson: true, includeToJson: false)
  final List<Donation>? donations;

  Patient({
    this.id,
    this.name,
    this.phone,
    this.address,
    this.township,
    this.ward,
    this.village,
    this.age,
    this.birthDate,
    this.gender,
    this.bloodType,
    this.medicalNotes,
    this.donationCount,
    this.createdAt,
    this.donations,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    // Parse donations manually since Donation uses a custom fromJson
    List<Donation>? donationsList;
    if (json['donations'] != null) {
      donationsList = (json['donations'] as List)
          .map((d) => Donation.fromJson(d as Map<String, dynamic>))
          .toList();
    }

    return Patient(
      id: json['id'] as int?,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      township: json['township'] as String?,
      ward: json['ward'] as String?,
      village: json['village'] as String?,
      age: json['age'] as String?,
      birthDate: json['birth_date'] as String?,
      gender: json['gender'] as String?,
      bloodType: json['blood_type'] as String?,
      medicalNotes: json['medical_notes'] as String?,
      donationCount: json['donation_count'] as int?,
      createdAt: json['created_at'] as String?,
      donations: donationsList,
    );
  }

  Map<String, dynamic> toJson() => _$PatientToJson(this);
}
