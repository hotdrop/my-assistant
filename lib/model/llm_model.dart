enum LlmModel {
  gpt3(gpt3ModelName, 4096, 1000, 0.002),
  gpt4(gpt4ModelName, 8192, 1000, 0.03),
  dallE(imageModelName, -1, 1, 0.018); // 512 * 512 で計算 https://openai.com/pricing

  final String name;
  final int maxContext;
  final int amountPerTokenNum;
  final double amountDollerPerTokenNum;

  static const gpt3ModelName = 'gpt-3.5-turbo';
  static const gpt4ModelName = 'gpt-4';
  static const imageModelName = 'DALL-E';

  const LlmModel(
    this.name,
    this.maxContext,
    this.amountPerTokenNum,
    this.amountDollerPerTokenNum,
  );

  static LlmModel toModel(String name) {
    if (name == LlmModel.gpt3ModelName) {
      return LlmModel.gpt3;
    } else if (name == LlmModel.gpt4ModelName) {
      return LlmModel.gpt4;
    } else if (name == LlmModel.imageModelName) {
      return LlmModel.dallE;
    } else {
      throw UnsupportedError('$name は未サポートのモデルです');
    }
  }
}
