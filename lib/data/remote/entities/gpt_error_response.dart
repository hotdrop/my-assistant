import 'package:assistant_me/model/app_exception.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'gpt_error_response.freezed.dart';
part 'gpt_error_response.g.dart';

@freezed
class GptErrorResponse with _$GptErrorResponse {
  factory GptErrorResponse({
    @JsonKey(name: 'error') required GptErrorDetailResponse error,
  }) = _GptErrorResponse;

  factory GptErrorResponse.fromJson(Map<String, Object?> json) => _$GptErrorResponseFromJson(json);
}

@freezed
abstract class GptErrorDetailResponse implements _$GptErrorDetailResponse {
  const GptErrorDetailResponse._();
  factory GptErrorDetailResponse({
    @JsonKey(name: 'code') required String code,
    @JsonKey(name: 'message') required String message,
    @JsonKey(name: 'type') required String type,
    @JsonKey(name: 'param') required String param,
  }) = _GptErrorDetailResponse;

  factory GptErrorDetailResponse.fromJson(Map<String, Object?> json) => _$GptErrorDetailResponseFromJson(json);

  static final RegExp _regExpOnlyAllNumber = RegExp(r'\b\d+\b');

  bool isOverTokenError() {
    return code == 'context_length_exceeded';
  }

  int getOverTokenNum() {
    if (!isOverTokenError()) {
      throw AppException(message: 'エラーコードがcontext_length_exceededでないのに超過トークン数の取得処理が呼ばれました。プログラムを見直してください code=$code');
    }

    // 「This model's maximum context length ...」のエラーのみここにくるはずなので2つ目の数値を取得して返す
    final overLimitTokenNumStr = _regExpOnlyAllNumber.allMatches(message).elementAt(1).group(0) ?? "";
    return int.parse(overLimitTokenNumStr);
  }
}
