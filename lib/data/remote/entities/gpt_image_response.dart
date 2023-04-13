import 'package:freezed_annotation/freezed_annotation.dart';

part 'gpt_image_response.freezed.dart';
part 'gpt_image_response.g.dart';

@freezed
class GptImageResponse with _$GptImageResponse {
  factory GptImageResponse({
    @JsonKey(name: 'created') required int epoch,
    @JsonKey(name: 'data') required List<ImageUrlResponse> urls,
  }) = _GptImageResponse;
  factory GptImageResponse.fromJson(Map<String, Object?> json) => _$GptImageResponseFromJson(json);
}

@freezed
class ImageUrlResponse with _$ImageUrlResponse {
  factory ImageUrlResponse({
    @JsonKey(name: 'url') required String url,
  }) = _ImageUrlResponse;
  factory ImageUrlResponse.fromJson(Map<String, Object?> json) => _$ImageUrlResponseFromJson(json);
}
