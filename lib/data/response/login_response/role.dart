import 'package:json_annotation/json_annotation.dart';

import 'name.dart';

part 'role.g.dart';

@JsonSerializable()
class Role {
  int? id;
  Name? name;
  String? slug;
  List<String>? permissions;
  int? level;
  @JsonKey(name: 'company_id')
  dynamic companyId;
  @JsonKey(name: 'created_at')
  String? createdAt;
  @JsonKey(name: 'updated_at')
  String? updatedAt;

  Role({
    this.id,
    this.name,
    this.slug,
    this.permissions,
    this.level,
    this.companyId,
    this.createdAt,
    this.updatedAt,
  });

  factory Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);

  Map<String, dynamic> toJson() => _$RoleToJson(this);
}
