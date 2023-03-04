import 'package:freezed_annotation/freezed_annotation.dart';

part 'gpt_response.freezed.dart';
part 'gpt_response.g.dart';

@freezed
class GptResponse with _$GptResponse {
  factory GptResponse({
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'object') required String gptObject,
    @JsonKey(name: 'created') required int epoch,
    @JsonKey(name: 'choices') required List<ChoiceResponse> choices,
    @JsonKey(name: 'usage') required UsageResponse usage,
  }) = _GptResponse;
  factory GptResponse.fromJson(Map<String, Object?> json) => _$GptResponseFromJson(json);
}

@freezed
class ChoiceResponse with _$ChoiceResponse {
  factory ChoiceResponse({
    @JsonKey(name: 'index') required int index,
    @JsonKey(name: 'message') required MessageResponse message,
    @JsonKey(name: 'finish_reason') required String finishReason,
  }) = _ChoiceResponse;
  factory ChoiceResponse.fromJson(Map<String, Object?> json) => _$ChoiceResponseFromJson(json);
}

@freezed
class MessageResponse with _$MessageResponse {
  factory MessageResponse({
    @JsonKey(name: 'role') required String role,
    @JsonKey(name: 'content') required String content,
  }) = _MessageResponse;
  factory MessageResponse.fromJson(Map<String, Object?> json) => _$MessageResponseFromJson(json);
}

@freezed
class UsageResponse with _$UsageResponse {
  factory UsageResponse({
    @JsonKey(name: 'prompt_tokens') required int promptTokens,
    @JsonKey(name: 'completion_tokens') required int completionTokens,
    @JsonKey(name: 'total_tokens') required int totalTokens,
  }) = _UsageResponse;
  factory UsageResponse.fromJson(Map<String, Object?> json) => _$UsageResponseFromJson(json);
}

extension DateTimeConverter on int {
  DateTime toDateTime() {
    return DateTime.fromMillisecondsSinceEpoch(this * 1000);
  }
}
