class BlogModel {
  final String blogPostId;
  final String title;
  final String message;
  final String link;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Social fields
  final bool postedToFacebook;
  final String? facebookPostId;
  final bool postedToLinkedIn;
  final String? linkedInPostId;
  final bool postedToBlogger;
  final String? bloggerPostId;

  BlogModel({
    required this.blogPostId,
    required this.title,
    required this.message,
    required this.link,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.postedToFacebook = false,
    this.facebookPostId,
    this.postedToLinkedIn = false,
    this.linkedInPostId,
    this.postedToBlogger = false,
    this.bloggerPostId,
  });

  factory BlogModel.fromJson(Map<String, dynamic> json) {
    return BlogModel(
      blogPostId: json['blogPostId'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      link: json['link'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
      postedToFacebook: json['postedToFacebook'] ?? false,
      facebookPostId: json['facebookPostId'],
      postedToLinkedIn: json['postedToLinkedIn'] ?? false,
      linkedInPostId: json['linkedInPostId'],
      postedToBlogger: json['postedToBlogger'] ?? false,
      bloggerPostId: json['bloggerPostId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'blogPostId': blogPostId,
      'title': title,
      'message': message,
      'link': link,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'postedToFacebook': postedToFacebook,
      'facebookPostId': facebookPostId,
      'postedToLinkedIn': postedToLinkedIn,
      'linkedInPostId': linkedInPostId,
      'postedToBlogger': postedToBlogger,
      'bloggerPostId': bloggerPostId,
    };
  }
} 