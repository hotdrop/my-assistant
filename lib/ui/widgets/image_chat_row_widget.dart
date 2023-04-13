import 'package:assistant_me/model/talk.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class ImageChatRowWidget extends StatelessWidget {
  const ImageChatRowWidget({super.key, required Talk talk}) : imageTalk = (talk as ImageTalk);

  final ImageTalk imageTalk;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const SizedBox(width: 32),
        Flexible(
          child: Card(
            elevation: 1.0,
            color: Theme.of(context).colorScheme.background,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Wrap(
                runSpacing: 16,
                spacing: 16,
                children: imageTalk.getValue().map((e) => _ImageView(url: e)).toList(),
              ),
            ),
          ),
        ),
        Image.asset('assets/images/ic_assistant.png', width: 24, height: 24),
        const SizedBox(width: 8),
      ],
    );
  }
}

class _ImageView extends StatelessWidget {
  const _ImageView({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    // イメージをダウンロードできるようにしたいが微妙に面倒臭そうなので要検討
    return ExtendedImage.network(
      url,
      width: 350,
      height: 350,
      fit: BoxFit.fill,
      cache: true,
      border: Border.all(width: 1.0),
    );
  }
}
