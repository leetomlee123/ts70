import 'package:equatable/equatable.dart';

class Chapter {
  String? name;
  String? index;

  Chapter({this.name, this.index});
}
class DataSearch{
  String? label;
  List<Search>? data;
  DataSearch({this.data,this.label});
}
class TopRank {
  String? name;
  String? a;
  String? b;
  String? id;

  TopRank({this.a, this.b, this.id, this.name});
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
  int? position;
  int? duration;
  int? buffer;

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
    int? position,
    int? duration,
    int? buffer
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
        buffer: buffer??this.buffer
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
    this.position = 0,
    this.duration = 1,
    this.buffer=0
  });

  Search.fromJson(Map<dynamic, dynamic> json) {
    id = json['id'].toString();
    title = json['title'];
    url = json['url'];
    bookMeta = json['book_meta'];
    lastTime = json['last_time'];
    idx = json['idx'];
    position = json['position'] ?? 0;
    duration = json['duration'] ?? 1;
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
    data['position'] = position;
    data['duration'] = duration ?? 1;
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
  }
}
