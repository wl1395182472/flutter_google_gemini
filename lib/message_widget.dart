import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'code_wrapper.dart';
import 'message_model.dart';

class MessageWidget extends StatelessWidget {
  final MyMessage item;

  const MessageWidget({
    super.key,
    required this.item,
  });

  CodeWrapperWidget codeWrapper(child, text, language) => CodeWrapperWidget(
        child,
        text,
        language,
      );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final config =
        isDark ? MarkdownConfig.darkConfig : MarkdownConfig.defaultConfig;

    return Row(
      children: [
        Expanded(
          child: Align(
            alignment:
                item.isHuman ? Alignment.centerRight : Alignment.centerLeft,
            child: Card(
              color: item.type == MessageType.error
                  ? Theme.of(context).colorScheme.errorContainer
                  : item.type == MessageType.log
                      ? Theme.of(context).colorScheme.tertiaryContainer
                      : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                ),
                child: MarkdownBlock(
                  data: item.content,
                  config: config.copy(
                    configs: [
                      isDark
                          ? PreConfig.darkConfig.copy(wrapper: codeWrapper)
                          : const PreConfig().copy(wrapper: codeWrapper),
                      LinkConfig(
                        style: const TextStyle(
                          color: Colors.red,
                          decoration: TextDecoration.underline,
                        ),
                        onTap: (url) async {
                          if (await canLaunchUrlString(url)) {
                            await launchUrlString(
                              url,
                              mode: LaunchMode.platformDefault,
                            );
                          }
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
