class BlogModel {
  final String id;
  final String title;
  final String content;
  final String author;
  final String imageUrl;
  final DateTime publishedDate;
  final List<String> tags;
  final int readTime; // in minutes
  final String category;
  final bool isFeatured;

  BlogModel({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.imageUrl,
    required this.publishedDate,
    required this.tags,
    required this.readTime,
    required this.category,
    this.isFeatured = false,
  });

  factory BlogModel.fromJson(Map<String, dynamic> json) {
    return BlogModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      author: json['author'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      publishedDate: DateTime.parse(json['publishedDate'] ?? DateTime.now().toIso8601String()),
      tags: List<String>.from(json['tags'] ?? []),
      readTime: json['readTime'] ?? 5,
      category: json['category'] ?? 'Health',
      isFeatured: json['isFeatured'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'author': author,
      'imageUrl': imageUrl,
      'publishedDate': publishedDate.toIso8601String(),
      'tags': tags,
      'readTime': readTime,
      'category': category,
      'isFeatured': isFeatured,
    };
  }

  BlogModel copyWith({
    String? id,
    String? title,
    String? content,
    String? author,
    String? imageUrl,
    DateTime? publishedDate,
    List<String>? tags,
    int? readTime,
    String? category,
    bool? isFeatured,
  }) {
    return BlogModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      author: author ?? this.author,
      imageUrl: imageUrl ?? this.imageUrl,
      publishedDate: publishedDate ?? this.publishedDate,
      tags: tags ?? this.tags,
      readTime: readTime ?? this.readTime,
      category: category ?? this.category,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }
} 