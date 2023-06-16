enum LlmModel {
  gpt3(gpt3ModelName, 4096),
  gpt3New(gpt3NewModelName, 4096),
  gpt3Model16k(gpt3Model16kName, 16000),
  gpt4(gpt4ModelName, 8192),
  dallE(imageModelName, -1);

  final String name;
  final int maxContext;

  static const gpt3ModelName = 'gpt-3.5-turbo';
  static const gpt3NewModelName = 'gpt-3.5-turbo-0613';
  static const gpt3Model16kName = 'gpt-3.5-turbo-16k';
  static const gpt4ModelName = 'gpt-4';
  static const imageModelName = 'DALL-E';

  const LlmModel(
    this.name,
    this.maxContext,
  );

  static LlmModel toModel(String name) {
    return switch (name) {
      LlmModel.gpt3ModelName => LlmModel.gpt3,
      LlmModel.gpt3NewModelName => LlmModel.gpt3New,
      LlmModel.gpt4ModelName => LlmModel.gpt4,
      LlmModel.imageModelName => LlmModel.dallE,
      _ => throw UnsupportedError('$name は未サポートのモデルです'),
    };
  }
}
