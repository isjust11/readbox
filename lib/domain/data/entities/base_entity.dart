abstract class BaseEntity {
  BaseEntity();
  
  Map<String, dynamic> toJson();

  BaseEntity.fromJson(Map<String, dynamic> map);
}
