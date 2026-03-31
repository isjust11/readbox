class PageModel {
  final String? id;
  final String? slug;
  final String? title;
  final String? content;
  final String? metaTitle;
  final String? metaDescription;
  final String? thumbnail;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
  final String? linkPages;

  PageModel({
    required this.id,
    required this.slug,
    required this.title,
    required this.content,
    required this.metaTitle,
    required this.metaDescription,
    required this.thumbnail,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.linkPages,
  });

  factory PageModel.fromJson(Map<String, dynamic> map) {
    return PageModel(
      id: map['id'],
      slug: map['slug'],
      title: map['title'],
      content: map['content'],
      metaTitle: map['metaTitle'],
      metaDescription: map['metaDescription'],
      thumbnail: map['thumbnail'],
      linkPages: map['linkPages'],
      isActive: map['isActive'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'slug': slug,
      'title': title,
      'content': content,
      'metaTitle': metaTitle,
      'metaDescription': metaDescription,
      'thumbnail': thumbnail,
      'linkPages': linkPages,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
