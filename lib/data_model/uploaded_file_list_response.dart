import 'dart:convert';

UploadedFilesListResponse uploadedFilesListResponseFromJson(String str) =>
    UploadedFilesListResponse.fromJson(json.decode(str));

String uploadedFilesListResponseToJson(UploadedFilesListResponse data) =>
    json.encode(data.toJson());

class UploadedFilesListResponse {
  UploadedFilesListResponse({
    this.data,
    this.links,
    this.meta,
    this.result,
    this.status,
  });

  List<FileInfo>? data;
  Links? links;
  Meta? meta;
  bool? result;
  var status;

  factory UploadedFilesListResponse.fromJson(Map<String, dynamic> json) =>
      UploadedFilesListResponse(
        data:
            List<FileInfo>.from(json["data"].map((x) => FileInfo.fromJson(x))),
        links: json["links"] != null ? Links.fromJson(json["links"]) : null,
        meta: json["meta"] != null ? Meta.fromJson(json["meta"]) : null,
        result: json["result"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
        "links": links?.toJson(),
        "meta": meta?.toJson(),
        "result": result,
        "status": status,
      };
}

class FileInfo {
  FileInfo({
    this.id,
    this.fileOriginalName,
    this.fileName,
    this.url,
    this.fileSize,
    this.extension,
    this.type,
  });

  var id;
  String? fileOriginalName;
  String? fileName;
  String? url;
  var fileSize;
  String? extension;
  String? type;

  factory FileInfo.fromJson(Map<String, dynamic> json) => FileInfo(
        id: json["id"],
        fileOriginalName: json["file_original_name"],
        fileName: json["file_name"],
        url: json["url"],
        fileSize: json["file_size"],
        extension: json["extension"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "file_original_name": fileOriginalName,
        "file_name": fileName,
        "url": url,
        "file_size": fileSize,
        "extension": extension,
        "type": type,
      };
}

class Links {
  Links({
    this.first,
    this.last,
    this.prev,
    this.next,
  });

  String? first;
  String? last;
  dynamic prev;
  dynamic next;

  factory Links.fromJson(Map<String, dynamic> json) => Links(
        first: json["first"],
        last: json["last"],
        prev: json["prev"],
        next: json["next"],
      );

  Map<String, dynamic> toJson() => {
        "first": first,
        "last": last,
        "prev": prev,
        "next": next,
      };
}

class Meta {
  Meta({
    this.currentPage,
    this.from,
    this.lastPage,
    this.links,
    this.path,
    this.perPage,
    this.to,
    this.total,
  });

  var currentPage;
  var from;
  var lastPage;
  List<Link>? links;
  String? path;
  var perPage;
  var to;
  var total;

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
        currentPage: json["current_page"],
        from: json["from"],
        lastPage: json["last_page"],
        links: List<Link>.from(json["links"].map((x) => Link.fromJson(x))),
        path: json["path"],
        perPage: json["per_page"],
        to: json["to"],
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
        "current_page": currentPage,
        "from": from,
        "last_page": lastPage,
        "links": List<dynamic>.from(links!.map((x) => x.toJson())),
        "path": path,
        "per_page": perPage,
        "to": to,
        "total": total,
      };
}

class Link {
  Link({
    this.url,
    this.label,
    this.active,
  });

  String? url;
  String? label;
  bool? active;

  factory Link.fromJson(Map<String, dynamic> json) => Link(
        url: json["url"] == null ? null : json["url"],
        label: json["label"],
        active: json["active"],
      );

  Map<String, dynamic> toJson() => {
        "url": url == null ? null : url,
        "label": label,
        "active": active,
      };
}
