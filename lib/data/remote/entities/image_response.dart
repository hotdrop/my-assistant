import 'package:freezed_annotation/freezed_annotation.dart';

part 'image_response.freezed.dart';
part 'image_response.g.dart';

@freezed
class IamgeResponse with _$IamgeResponse {
  factory IamgeResponse({
    @JsonKey(name: 'created') required int createdAt,
    @JsonKey(name: 'data') required List<UrlResponse> urls,
  }) = _IamgeResponse;
  factory IamgeResponse.fromJson(Map<String, Object?> json) => _$IamgeResponseFromJson(json);
}

@freezed
class UrlResponse with _$UrlResponse {
  factory UrlResponse({
    @JsonKey(name: 'url') required String url,
  }) = _UrlResponse;
  factory UrlResponse.fromJson(Map<String, Object?> json) => _$UrlResponseFromJson(json);
}
