import 'package:common_utils/common_utils.dart';
class Chapter {
  String? cover;
  String? bookMeta;
}

class Search {
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
  Search({
    this.id,
    this.desc,
    this.url = '',
    this.bookMeta,
    this.cover,
    this.lastTime=0,
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
    lastTime=json['last_time'];
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
    data['last_time']=lastTime??0;
    data['cover'] = cover;
    data['position'] = position!.inMilliseconds;
    data['duration'] = duration?.inSeconds ?? 1;
    data['count'] = count;
    data['title'] = title;
    return data;
  }
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
