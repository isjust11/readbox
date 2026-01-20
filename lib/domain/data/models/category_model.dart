import 'package:readbox/domain/data/entities/entities.dart';

class CategoryModel extends CategoryEntity {
  CategoryModel({
    super.id,
    super.name,
    super.description,
    super.icon,
    super.iconType,
    super.iconSize,
    super.className,
    super.isActive,
    super.code,
    super.allowEdit,
    super.categoryTypeId,
    super.sortOrder,
    super.isDefault,
    super.createBy,
    super.createdAt,
    super.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      description: json['description']?.toString(),
      icon: json['icon']?.toString(),
      iconType: json['iconType']?.toString(),
      iconSize: json['iconSize']?.toString(),
      className: json['className']?.toString(),
      isActive: json['isActive'],
      code: json['code']?.toString(),
      allowEdit: json['allowEdit'],
      categoryTypeId: json['categoryTypeId']?.toString(),
      sortOrder: json['sortOrder']?.toInt(),
      isDefault: json['isDefault'],
      createBy: json['createBy']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      icon: entity.icon,
      iconType: entity.iconType,
      iconSize: entity.iconSize,
      className: entity.className,
      isActive: entity.isActive,
      code: entity.code,
      allowEdit: entity.allowEdit,
      categoryTypeId: entity.categoryTypeId,
      sortOrder: entity.sortOrder,
      isDefault: entity.isDefault,
      createBy: entity.createBy,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      description: description,
      icon: icon,
      iconType: iconType,
      iconSize: iconSize,
      className: className,
      isActive: isActive,
      code: code,
      allowEdit: allowEdit,
      categoryTypeId: categoryTypeId,
      sortOrder: sortOrder,
      isDefault: isDefault,
      createBy: createBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
