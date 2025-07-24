import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:nigerian_igbo/app/data/config/logger.dart';
import '../models/chat_event.dart';


/// Main mixin to handle HTML stream parsing into `ChatEventModel`
mixin HtmlDataMixin on GetxController {
  /// Reactive list that gets updated as events stream in
  final RxList<ChatEventModel> chatEvent = <ChatEventModel>[].obs;

  /// Internal buffer for message-type events (can be joined)
  final StringBuffer _messageBuffer = StringBuffer();

  /// Scroll controller for the chat view
  final ScrollController scrollController = ScrollController();

  /// Text editing controller for the chat input field
  final TextEditingController chatInputController = TextEditingController();

  /// Writing state for when content is being streamed/written
  final RxBool isWriting = false.obs;

  /// Abstract method to be implemented by StreamHandlerMixin
  Future<void> processStream(Stream<List<int>> byteStream);

  /// Loads streamed response from server and maps it to ChatEventModel
  Future<void> loadStreamedHtmlContent() async {
    final String prompt = chatInputController.text.trim();
    chatInputController.clear();

    _messageBuffer.clear();

    // Set writing state
    isWriting.value = true;

    // Add new chat event to the list
    chatEvent.add(ChatEventModel());

    final String encodedPrompt = Uri.encodeComponent(prompt);
    final String url = _buildApiUrl(encodedPrompt);

    final Dio dio = Dio();

    try {
      final Response<ResponseBody> response = await dio.get<ResponseBody>(
        url,
        options: Options(responseType: ResponseType.stream),
      );

      await processStream(response.data!.stream);
    } on DioException catch (e) {
      logWTF('HtmlDataMixin: DioException: ${e.message}');
    } catch (e) {
      logWTF('HtmlDataMixin: Exception: $e');
    } finally {
      // Reset writing state when streaming is complete
      isWriting.value = false;
    }
  }

  /// Builds the API URL with encoded prompt
  String _buildApiUrl(String encodedPrompt) => 'https://stagingapi.search.com/search'
      '?prompt=$encodedPrompt'
      '&nt=0'
      '&key=JiMmNjQ_OS43PSE,'
      '&auth=Iw,,'
      '&sub='
      '&currentChatId=chat_6881d4beb6c0b'
      '&is_image='
      '&image_url='
      '&space_id='
      '&source_link_res=true'
      '&uid=YUlRZGNaMzRDVGx5ekg0TXgwSU5zQT09';

  /// Scrolls to bottom of the chat view
  void scrollToBottom() {
    // if (!scrollController.hasClients) {
    //   return;
    // }
    //
    // final double targetPosition = scrollController.position.maxScrollExtent;
    //
    // scrollController.animateTo(
    //   targetPosition,
    //   duration: const Duration(milliseconds: 600),
    //   curve: Curves.easeOut,
    // );
  }

  // /Expose message buffer for other mixins
  StringBuffer get messageBuffer => _messageBuffer;
}
