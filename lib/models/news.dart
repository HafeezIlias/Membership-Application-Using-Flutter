class News {
  String? newsId;
  String? newsTitle;
  String? newsDetails;
  String? newsDate;
  int likes;
  int dislikes;
  bool isLiked; // Tracks if the current user liked this news
  bool isDisliked; // Tracks if the current user disliked this news

  News({
    this.newsId,
    this.newsTitle,
    this.newsDetails,
    this.newsDate,
    this.likes = 0,
    this.dislikes = 0,
    this.isLiked = false,
    this.isDisliked = false,
  });

  News.fromJson(Map<String, dynamic> json)
      : newsId = json['news_id'],
        newsTitle = json['news_title'],
        newsDetails = json['news_details'],
        newsDate = json['news_date'],
        likes = int.tryParse(json['likes']?.toString() ?? '0') ?? 0,
        dislikes = int.tryParse(json['dislikes']?.toString() ?? '0') ?? 0,
        isLiked = json['is_liked'] == true, // Deserialize `isLiked`
        isDisliked = json['is_disliked'] == true; // Deserialize `isDisliked`

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['news_id'] = newsId;
    data['news_title'] = newsTitle;
    data['news_details'] = newsDetails;
    data['news_date'] = newsDate;
    data['likes'] = likes;
    data['dislikes'] = dislikes;
    data['is_liked'] = isLiked; // Serialize `isLiked`
    data['is_disliked'] = isDisliked; // Serialize `isDisliked`
    return data;
  }
}
