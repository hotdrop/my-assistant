enum LlmModel {
  gpt3(gpt3ModelName, 4096),
  gpt4(gpt4ModelName, 8192),
  dallE(imageModelName, -1);

  final String name;
  final int maxContext;

  static const gpt3ModelName = 'gpt-3.5-turbo';
  static const gpt4ModelName = 'gpt-4';
  static const imageModelName = 'DALL-E';

  const LlmModel(
    this.name,
    this.maxContext,
  );

  static LlmModel toModel(String name) {
    return switch (name) {
      LlmModel.gpt3ModelName => LlmModel.gpt3,
      LlmModel.gpt4ModelName => LlmModel.gpt4,
      LlmModel.imageModelName => LlmModel.dallE,
      _ => throw UnsupportedError('$name は未サポートのモデルです'),
    };
  }
}
