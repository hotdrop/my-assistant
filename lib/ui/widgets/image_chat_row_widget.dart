import 'package:assistant_me/common/app_theme.dart';
import 'package:assistant_me/model/talk.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';

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
    // SizedBoxでラップしないとwidthが100%になってしまう
    return SizedBox(
      width: 350,
      height: 350,
      child: ImageNetwork(
        image: url,
        imageCache: FastCachedImageProvider(url),
        width: 350,
        height: 350,
        onPointer: true,
        onLoading: const CircularProgressIndicator(
          color: AppTheme.primaryColor,
        ),
        onTap: () {
          // TODO イメージをダウンロードできるようにすると便利だけど、現状はそこまでDALL-Eの精度が高くないのでダウンロードしようと思わないので後回し
        },
      ),
    );
  }
}
