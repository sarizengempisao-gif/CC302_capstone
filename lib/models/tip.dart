/// A single tip/quote displayed by the Tips screen.
///
/// Tips come from a free public quotes API, but a few are also seeded
/// locally so the app still has useful content when the device is offline.
class Tip {
  final String id;
  final String content;
  final String author;

  const Tip({required this.id, required this.content, this.author = 'TaxiGo Tips'});

  Map<String, dynamic> toJson() => {
          'id': id,
          'content': content,
          'author': author,
        };

  factory Tip.fromJson(Map<String, dynamic> json) => Tip(
        id: (json['_id'] ?? json['id'] ?? '').toString(),
        content: (json['content'] ?? '').toString(),
        author: (json['author'] ?? 'TaxiGo Tips').toString(),
      );
}
