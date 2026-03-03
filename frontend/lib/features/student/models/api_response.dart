/// Generic API response wrapper (matches backend ApiResponse<T>).
class ApiResponse<T> {
  final String message;
  final T? data;
  final bool success;

  const ApiResponse({
    required this.message,
    this.data,
    required this.success,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) =>
      ApiResponse(
        message: json['message'] as String? ?? '',
        data: json['data'] != null && fromJsonT != null
            ? fromJsonT(json['data'])
            : null,
        success: json['success'] as bool? ?? false,
      );

  @override
  String toString() => 'ApiResponse(success: $success, message: $message)';
}

/// Error response from the backend (matches backend ErrorResponse).
class ErrorResponse {
  final String message;
  final int status;
  final int timestamp;

  const ErrorResponse({
    required this.message,
    required this.status,
    required this.timestamp,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) => ErrorResponse(
        message: json['message'] as String? ?? 'Unknown error',
        status: json['status'] as int? ?? 500,
        timestamp: json['timestamp'] as int? ?? 0,
      );

  @override
  String toString() => 'ErrorResponse(status: $status, message: $message)';
}

/// Pagination metadata for list endpoints.
class PaginationMeta {
  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;

  const PaginationMeta({
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) => PaginationMeta(
        page: json['page'] as int? ?? 0,
        pageSize: json['pageSize'] as int? ?? 10,
        totalItems: json['totalItems'] as int? ?? 0,
        totalPages: json['totalPages'] as int? ?? 0,
      );

  bool get hasNextPage => page < totalPages - 1;
  bool get hasPreviousPage => page > 0;

  @override
  String toString() =>
      'PaginationMeta(page: $page/$totalPages, total: $totalItems)';
}

/// Paginated list response wrapper.
class PaginatedResponse<T> {
  final List<T> items;
  final PaginationMeta meta;

  const PaginatedResponse({
    required this.items,
    required this.meta,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) =>
      PaginatedResponse(
        items: (json['items'] as List?)
                ?.map((e) => fromJsonT(e as Map<String, dynamic>))
                .toList() ??
            [],
        meta: PaginationMeta.fromJson(
          json['meta'] as Map<String, dynamic>? ?? {},
        ),
      );

  @override
  String toString() =>
      'PaginatedResponse(items: ${items.length}, meta: $meta)';
}
