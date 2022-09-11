import 'package:equatable/equatable.dart';

class Chapter {
  String? name;
  String? index;

  Chapter({this.name, this.index});
}

class TopRank {
  String? name;
  String? a;
  String? b;
  String? id;
  TopRank({this.a, this.b,this.id, this.name});
}

class Search extends Equatable {
  String? id;
  String? cover;
  String? bookMeta;
  String? title;
  String? desc;
  String? url;
  int? lastTime;
  int? idx;
  int? count;
  Duration? position;
  Duration? duration;

  Search copyWith({
    String? id,
    String? cover,
    String? bookMeta,
    String? title,
    String? desc,
    String? url,
    int? lastTime,
    int? idx,
    int? count,
    Duration? position,
    Duration? duration,
  }) =>
      Search(
        id: id ?? this.id,
        cover: cover ?? this.cover,
        bookMeta: bookMeta ?? this.bookMeta,
        title: title ?? this.title,
        desc: desc ?? this.desc,
        url: url ?? this.url,
        lastTime: lastTime ?? this.lastTime,
        idx: idx ?? this.idx,
        count: count ?? this.count,
        position: position ?? this.position,
        duration: duration ?? this.duration,
      );

  Search({
    this.id,
    this.desc,
    this.url = '',
    this.bookMeta,
    this.cover,
    this.lastTime = 0,
    this.title,
    this.idx = 0,
    this.count = 0,
    this.position = Duration.zero,
    this.duration = const Duration(seconds: 1),
  });

  Search.fromJson(Map<dynamic, dynamic> json) {
    id = json['id'].toString();
    title = json['title'];
    url = json['url'];
    bookMeta = json['book_meta'];
    lastTime = json['last_time'];
    idx = json['idx'];
    position = Duration(milliseconds: json['position'] ?? 0);
    duration = Duration(seconds: json['duration'] ?? 1);
    cover = json['cover'];
    count = json['count'];
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['book_meta'] = bookMeta;
    data['url'] = url;
    data['idx'] = idx ?? 0;
    data['last_time'] = lastTime ?? 0;
    data['cover'] = cover;
    data['position'] = position!.inMilliseconds;
    data['duration'] = duration?.inSeconds ?? 1;
    data['count'] = count;
    data['title'] = title;
    return data;
  }

  @override
  List<Object?> get props => [
        id,
        cover,
        bookMeta,
        title,
        desc,
        url,
        lastTime,
        idx,
        count,
        position,
        duration,
      ];
}

class Item {
  String? title;
  String? link;

  Item({
    this.link,
    this.title,
  });

  Item.fromJson(Map<String, dynamic> json) {
    link = json['link'];
    title = json['title'];

    Map<String, dynamic> toJson() {
      final Map<String, dynamic> data = <String, dynamic>{};
      data['link'] = link;
      data['title'] = title;

      return data;
    }
  }
}
