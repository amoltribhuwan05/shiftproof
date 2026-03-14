class PaginationMeta {
  const PaginationMeta({this.page, this.total, this.totalPages});

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      page: json['page'] as int?,
      total: json['total'] as int?,
      totalPages: json['totalPages'] as int?,
    );
  }
  final int? page;
  final int? total;
  final int? totalPages;

  Map<String, dynamic> toJson() {
    return {
      if (page != null) 'page': page,
      if (total != null) 'total': total,
      if (totalPages != null) 'totalPages': totalPages,
    };
  }
}

class PaginatedResponse<T> {
  const PaginatedResponse({required this.data, this.meta});

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => fromJsonT(e as Map<String, dynamic>))
              .toList() ??
          [],
      meta: json['meta'] == null
          ? null
          : PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }
  final List<T> data;
  final PaginationMeta? meta;

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'data': data.map(toJsonT).toList(),
      if (meta != null) 'meta': meta!.toJson(),
    };
  }
}
