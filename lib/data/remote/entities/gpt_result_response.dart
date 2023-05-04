import 'package:assistant_me/data/remote/entities/gpt_error_response.dart';
import 'package:assistant_me/data/remote/entities/gpt_response.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'gpt_result_response.freezed.dart';

@freezed
class GptResultResponse with _$GptResultResponse {
  const factory GptResultResponse.success(GptResponse response) = OnGptResponseSuccess;
  const factory GptResultResponse.error(GptErrorResponse error) = OnGptResponseError;
}
