class ApiError {
  const ApiError({this.code, this.error});

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'] as int?,
      error: json['error'] as String?,
    );
  }
  final int? code;
  final String? error;

  Map<String, dynamic> toJson() {
    return {if (code != null) 'code': code, if (error != null) 'error': error};
  }
}
