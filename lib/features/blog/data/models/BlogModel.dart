class BlogModel {
  final String blogPostId;
  final String message;
  final String link;
  final String imageUrl;

  // Social fields
  final bool postedToFacebook;
  final String? facebookPostId;
  final bool postedToLinkedIn;
  final String? linkedInPostId;
  final bool postedToBlogger;
  final String? bloggerPostId;

  BlogModel({
    required this.blogPostId,
    required this.message,
    required this.link,
    required this.imageUrl,
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
      message: json['message'] ?? '',
      link: json['link'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
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
      'message': message,
      'link': link,
      'imageUrl': imageUrl,
      'postedToFacebook': postedToFacebook,
      'facebookPostId': facebookPostId,
      'postedToLinkedIn': postedToLinkedIn,
      'linkedInPostId': linkedInPostId,
      'postedToBlogger': postedToBlogger,
      'bloggerPostId': bloggerPostId,
    };
  }
} 