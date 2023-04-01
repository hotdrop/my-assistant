enum LlmModel {
  gpt3('gpt-3.5-turbo', 4096);

  final String name;
  final int maxContext;

  const LlmModel(this.name, this.maxContext);
}
