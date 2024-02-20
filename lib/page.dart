import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_gemini/message_widget.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'message_model.dart';

const model = 'gemini-pro';
const apiKey = 'AIzaSyB9QY598V--NNzRnbhpyVyafvP1yW_UoH0';
final safetySettings = [
  SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
  SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
];

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  /// 模型实例
  GenerativeModel? generativeModel;

  /// 是否在等待回答
  bool isLoading = false;

  /// 输出的消息列表
  final output = <MyMessage>[];

  /// 输入框控制器
  final textEditingController = TextEditingController();

  @override
  void initState() {
    initModel();
    super.initState();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  /// 初始化模型
  void initModel() {
    try {
      output.clear();
      isLoading = false;
      generativeModel = GenerativeModel(
        model: model,
        apiKey: apiKey,
        safetySettings: safetySettings,
      );
      printMessage(
        type: MessageType.log,
        content: 'initModel',
      );
    } catch (error) {
      printMessage(
        type: MessageType.error,
        content: 'initModel\nerror:$error',
      );
    }
  }

  /// 发送消息
  void onSend(String value) async {
    try {
      final content = [Content.text(value)];
      textEditingController.clear();
      printMessage(
        isHuman: true,
        content: value,
      );
      isLoading = true;
      final response = await generativeModel?.generateContent(content);
      isLoading = false;
      printMessage(
        content: response?.text ?? '',
      );
    } catch (error) {
      isLoading = false;
      printMessage(
        type: MessageType.error,
        content:
            'onSend\nerror:${error is UnsupportedUserLocation ? error.message : error}',
      );
    }
  }

  /// 输出消息
  void printMessage({
    bool? isHuman,
    MessageType? type,
    required String content,
  }) {
    if (kDebugMode) {
      print(content);
    }
    if (mounted) {
      setState(() {
        output.insert(
          0,
          MyMessage(
            isHuman: isHuman ?? false,
            type: type ?? MessageType.normal,
            content: content,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Google Gemini Model'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: initModel,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 5.0,
            horizontal: 10.0,
          ),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10.0),
                  padding: const EdgeInsets.symmetric(
                    vertical: 2.0,
                    horizontal: 5.0,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ListView.builder(
                          reverse: true,
                          padding: EdgeInsets.zero,
                          itemCount: output.length,
                          itemBuilder: (context, index) => MessageWidget(
                            item: output[index],
                          ),
                        ),
                      ),
                      if (isLoading)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 10.0,
                            ),
                            child: LoadingAnimationWidget.prograssiveDots(
                              color: Theme.of(context).colorScheme.primary,
                              size: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.fontSize ??
                                  16.0,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              TextField(
                autofocus: true,
                minLines: 1,
                maxLines: 5,
                controller: textEditingController,
                textInputAction: TextInputAction.send,
                onSubmitted: onSend,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 15.0,
                    vertical: 10.0,
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(
                      top: 3.0,
                      bottom: 3.0,
                      right: 5.0,
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        textEditingController.text += '\n';
                      },
                      child: const Text(
                        'Newline',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
