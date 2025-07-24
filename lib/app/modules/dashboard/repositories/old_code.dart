// newCallPrompt(String prompt, bool isRegenerate, bool isImageGenerated,
//     int count) async {
//   var url = "";
//   var encryptedIp =
//   GeneralMethods.encryptStr(CommonController.ipAddress.value);
//   var encryptedAuth = GeneralMethods.encryptStr(
//       CommonController.isLoggedIn.value ? "1" : "0");
//   var encryptedSubscribed = CommonController.premiumMemberStatus.value
//       ? GeneralMethods.encryptStr("1")
//       : "";
//   var path = uploadedImagePathList.isEmpty && documentPdfFilePathList.isEmpty
//       ? File("")
//       : uploadedImagePathList.isNotEmpty
//       ? File(uploadedImagePathList.first)
//       : File(documentPdfFilePathList.first);
//   if (CommonController.isLoggedIn.value) {
//     url =
//     "prompt=$prompt&nt$count&key=$encryptedIp&auth=$encryptedAuth&uid=${CommonController.uId.value}&sub=$encryptedSubscribed&currentChatId=${globalChatId.value}&is_image=${isImageGenerated ? "1" : ""}&image_url=${path.toStaring()}&source_link_res=true";
//   } else {
//     url =
//     "prompt=$prompt&nt=$count&key=$encryptedIp&auth=$encryptedAuth&is_image=${isImageGenerated ? "1" : ""}&image_url=${path.toString()}&source_link_res=true";
//   }
//
//   final response = await StreamingServices.searchPromptStreamedGet(url);
//   try {
//     if (response != null) {
//       chatList.removeLast(); // for loader
//       questionFocusNode.value.unfocus();
//       questionController.value.clear();
//       StringBuffer streamResponse = StringBuffer();
//       String previousResponse = "";
//       String notSafeEvent = "";
//       String testSourceLinkEvent = "";
//       String chatIdEvent = "";
//       String keywordEvent = "";
//       String shoppingBannerEvent = "";
//       String sourceLinkEvent = "";
//       String messageEventStatus = ""; // Use this to track if we're processing a message event
//       String messageCompleteEventStatus = ""; // Use this to track if we're processing a message_complete event
//       String followUpEvent = "";
//       bool startCollecting = false;
//       List<Map<String, String>> keywordMapList = [];
//       int nt = 0;
//       // StringBuffer shoppingBannerBuffer = StringBuffer();
//
//       await for (var line in response.stream
//           .transform(utf8.decoder)
//           .transform(const LineSplitter())) {
//         if (line.trim().isEmpty) {
//           continue;
//         } else {
//           if (line.startsWith("event: IPLimitExceeded")) {
//             debugPrint("ip limit exceeded");
//             chatList.removeLast();
//             limit.value = 0;
//             // DialogBoxes.showLimitExpiredBox(
//             //     heading: "You've reached the guest message limit",
//             //     subHeading: CommonController.isLoggedIn.value? "" :"Create a FREE account to continue searching!",
//             //     buttonMsg:  CommonController.isLoggedIn.value? "Upgrade" : "Create Account or Login", isLoggedFlag: CommonController.isLoggedIn.value);
//             return;
//           }
//           if (line.startsWith("event: not_safe")) {
//             notSafeEvent = "NotSafeEvent";
//             continue;
//           }
//           if (notSafeEvent == "NotSafeEvent") {
//             line = line.substring(5).trim();
//             line = line.replaceAll(RegExp(r'^"+|"+$'), '');
//             String cleaned = "";
//             var doc;
//             try {
//               cleaned = jsonDecode('"$line"');
//               doc = html_parser.parse(cleaned);
//               print(doc.body?.innerHtml);
//             } catch (e) {}
//
//             chatList.add(ChatHelperModel(
//               userType: UserType.bot,
//               messageType: MessageType.text,
//               message: doc.body?.innerHtml ??
//                   "Please verify you are 18 years of age or older by creating a FREE account to continue using search.comSign Up",
//               chatId: globalChatId.value,
//               index: chatList.length,
//               likeStatus: 2,
//               key: GlobalKey(),
//             ));
//             notSafeEvent = "";
//             return;
//           }
//           if (line == ('event: message')) {
//             messageEventStatus = "MessageEvent"; // Set flag to indicate next 'data:' belongs to 'message'
//             continue; // Go to the next line (which should be the 'data:' line)
//           }
//           if (messageEventStatus == "MessageEvent") {
//             startCollecting = true; // Indicate we are collecting the main message
//             nt++; // Increment chunk count
//             String rawData = line.substring(5).trim(); // Get data after "data: "
//             print('rawData ::: $rawData');
//             // Clean up and decode HTML chunks from the server
//             rawData = rawData.replaceAll(RegExp(r'^"+|"+$'), '');
//             rawData = rawData.replaceFirst(RegExp(r'^(n|\\n)(?=\s*<)'), '');
//             rawData = cleanHtmlResponse(rawData);
//
//             debugPrint("🟢 Collecting AI response chunk ($nt): $rawData");
//
//             if (streamResponse.isEmpty) {
//               // This is the first chunk of the message
//               if (chatList.last.isLoading) {
//                 chatList.removeLast(); // Remove loader
//               }
//               chatList.add(ChatHelperModel(
//                 userType: UserType.bot,
//                 messageType: MessageType.text,
//                 message: rawData, // Display the first chunk immediately
//                 chatId: globalChatId.value,
//                 index: chatList.length,
//                 likeStatus: 2,
//                 key: GlobalKey(),
//               ));
//               scrollToEnd();
//               streamResponse.write(rawData); // Start building the full response
//             } else {
//               // Append subsequent chunks
//               streamResponse.write(rawData);
//               chatList.last.message = cleanHtmlResponse(streamResponse.toString());
//               scrollToEnd();
//             }
//             chatList.refresh(); // Update UI
//             messageEventStatus = "";
//             continue; // Go to the next line in the stream
//           }
//           if (line.startsWith('event: message_complete')) {
//             messageCompleteEventStatus = "MessageCompleteEvent"; // Set flag
//             continue; // Go to the next line (which should be the 'data:' line)
//           }
//           if (messageCompleteEventStatus == "MessageCompleteEvent") {
//             debugPrint("🛑 Message complete event received. Stopping message collection.");
//             startCollecting = false; // Stop collecting the main message
//
//             // Ensure the last message is fully rendered after all chunks
//             if (chatList.isNotEmpty) {
//               chatList.last.message = cleanHtmlResponse(streamResponse.toString());
//               chatList.refresh();
//             }
//             streamResponse.clear(); // Clear buffer for the next message
//             messageCompleteEventStatus = "";
//             continue; // Go to the next line in the stream
//           } else {
//             debugPrint("stream response : $line");
//             final aiResponseKeyRegex =
//             RegExp(r'"ai_response\\?"\s*:\s*\\?"', caseSensitive: false);
//             var rawData = line.isNotEmpty ? line : "";
//             // rawData = rawData.replaceAll(r'\"', '"').trim();
//             /// for sourceLinks
//             if (line.startsWith("event: sourceLinks")) {
//               sourceLinkEvent = "SourceLinkEvent";
//               continue;
//             }
//
//             if (sourceLinkEvent == "SourceLinkEvent") {
//               debugPrint("adding sources");
//               try {
//                 rawData = line.substring(5).trim();
//                 rawData = rawData.replaceAll(RegExp(r'^"+|"+$'), '');
//                 debugPrint("sources $rawData");
//                 rawData = sourceLinkCleaner1(rawData);
//                 debugPrint("sources $rawData");
//                 // if(streamResponse.isEmpty){
//                 String cleaned =
//                 rawData.replaceFirst(RegExp(r'^.*?(?=<div)'), '');
//                 final document = html_parser.parse(rawData);
//                 final sourceBlock =
//                 document.querySelector('.ai-source-link-block');
//                 String? sourceHtml;
//
//                 if (sourceBlock != null) {
//                   sourceHtml = sourceBlock.outerHtml;
//                   sourceBlock.remove(); // remove from main doc
//                 }
//
//                 if (streamResponse.isEmpty) {
//                   debugPrint("➕ Adding new message before stopMarker");
//                   chatList.add(ChatHelperModel(
//                     userType: UserType.bot,
//                     messageType: MessageType.text,
//                     message: "",
//                     chatId: globalChatId.value,
//                     index: chatList.length,
//                     likeStatus: 2,
//                     sourceHtml: sourceHtml ?? "",
//                     key: GlobalKey(),
//                   ));
//                   scrollToEnd();
//                 } else {
//                   chatList.last.sourceHtml = sourceHtml ?? "";
//                 }
//
//                 chatList.refresh();
//               } on Exception catch (e) {
//                 debugPrint("Cannot parse source links");
//                 // TODO
//               }
//               sourceLinkEvent = "";
//               continue;
//             }
//
//             if (!startCollecting &&
//                 (rawData.contains('"ai_response"') ||
//                     rawData.contains('"ai_response\"') ||
//                     aiResponseKeyRegex.hasMatch(rawData))) {
//               debugPrint("Found ai response");
//               startCollecting = true;
//
//               final match = RegExp(r'"ai_response\\?"\s*:\s*\\?"(.*)$')
//                   .firstMatch(rawData);
//               if (match != null) {
//                 String initialHtml = match.group(1)!;
//
//                 // Clean up and decode
//                 initialHtml = initialHtml.replaceAll(RegExp(r'^"+|"+$'), '');
//                 initialHtml =
//                     initialHtml.replaceFirst(RegExp(r'^(n|\\n)(?=\s*<)'), '');
//                 initialHtml = cleanHtmlResponse(initialHtml);
//
//                 streamResponse.write(initialHtml);
//                 debugPrint(
//                     "🟢 Started collecting from ai_response same line: $initialHtml");
//                 if (chatList.last.isLoading) {
//                   chatList.removeLast(); // for loader
//                 }
//
//                 chatList.add(ChatHelperModel(
//                   userType: UserType.bot,
//                   messageType: MessageType.text,
//                   message: cleanHtmlResponse(streamResponse.toString()),
//                   chatId: globalChatId.value,
//                   index: chatList.length,
//                   likeStatus: 2,
//                   key: GlobalKey(),
//                 ));
//               }
//               continue; // go to next SSE line
//             }
//
//             if (startCollecting) {
//               nt++;
//               debugPrint("response number $nt");
//             }
//             bool isTopKeywordFound = false;
//             const stopMarker = r'\"topKeywords\"';
//
//             const endPatterns = [
//               '",\n  "topKeywords"',
//               '",\n  "topKeywords": [',
//               '" ,\n  "topKeywords"'
//                   '" ,\n  "topKeywords\"'
//             ];
//
//             final isStopLine = endPatterns
//                 .any((pattern) => line.contains(pattern)) ||
//                 line.contains('"topKeywords"') || // still handle minimal form
//                 line.contains(
//                     '"topKeywords\"') || // still handle minimal form
//                 line.contains('topKeywords');
//
//             if (previousResponse.isNotEmpty) {
//               var incomingMerge = line.substring(5).trim();
//               incomingMerge = cleanHtmlResponse(incomingMerge);
//               var mergedLine = previousResponse + incomingMerge;
//               debugPrint("merged line ${mergedLine}");
//               isTopKeywordFound = endPatterns
//                   .any((pattern) => mergedLine.contains(pattern)) ||
//                   mergedLine.contains(
//                       '"topKeywords"') || // still handle minimal form
//                   mergedLine.contains('topKeywords');
//             }
//             if (isStopLine || isTopKeywordFound) {
//               if (isTopKeywordFound && !isStopLine) {
//                 startCollecting = false;
//                 final tokens =
//                 previousResponse.trimRight().split(RegExp(r'\s+'));
//                 if (tokens.isNotEmpty) {
//                   tokens.removeLast(); // remove the partial or last word
//                   previousResponse = tokens.join(' ');
//                 } else {
//                   previousResponse = '';
//                 }
//                 continue;
//               } else {
//                 var parts;
//                 line = line.substring(5).trim();
//                 // line = line.replaceAll(RegExp(r'^"+|"+$'), '');
//                 // line = line.replaceFirst(RegExp(r'^(n|\\n)(?=\s*<)'), '');
//                 line = cleanHtmlResponse(line);
//                 debugPrint("Cleaned stream line $line");
//                 if (line.trim().startsWith("n  <")) {
//                   debugPrint("Gotcha ${line}");
//                   final firstTagIndex = line.indexOf('<');
//                   if (firstTagIndex > 0) {
//                     line = line.substring(firstTagIndex);
//                   }
//                 }
//                 if (line.contains(stopMarker)) {
//                   parts = line.split(stopMarker);
//                 } else if (line.contains("topKeywords")) {
//                   parts = line.split("topKeywords");
//                 }
//                 var beforeStop = parts.first.trim();
//                 int divEnd = beforeStop.indexOf('</div>');
//                 if (divEnd != -1) {
//                   beforeStop =
//                       beforeStop.substring(0, divEnd); // +6 to include </div>
//                 }
//                 var parsedHtml = cleanHtmlResponse(beforeStop.trim());
//                 parsedHtml = parsedHtml
//                     .replaceAll(RegExp(r'^"+|"+$'), '')
//                     .replaceAll(RegExp(r'[,"]+\s*$'), '')
//                     .trim();
//                 if (parsedHtml == '",') {
//                   debugPrint("Problem");
//                 }
//                 if (streamResponse.isEmpty) {
//                   streamResponse.write(parsedHtml.trim());
//                   debugPrint("➕ Adding new message before stopMarker");
//                   chatList.add(ChatHelperModel(
//                     userType: UserType.bot,
//                     messageType: MessageType.text,
//                     message:
//                     cleanHtmlResponse(streamResponse.toString().trim()),
//                     chatId: globalChatId.value,
//                     index: chatList.length,
//                     likeStatus: 2,
//                     key: GlobalKey(),
//                   ));
//                   scrollToEnd();
//                 } else {
//                   streamResponse.write(parsedHtml.trim());
//                   debugPrint("🔁 Updating last message before stopMarker");
//
//                   chatList.last.message =
//                       cleanHtmlResponse(streamResponse.toString().trim());
//                   scrollToEnd();
//                 }
//                 chatList.refresh();
//
//                 debugPrint("🛑 Found \"$stopMarker\" — Stopping collection.");
//                 startCollecting = false;
//                 continue; // ✅ Continue the loop to let ChatHistoryId event work
//               }
//             }
//             if (startCollecting) {
//               rawData = line.substring(5).trim();
//               // rawData = rawData.replaceAll(RegExp(r'^"+|"+$'), '');
//               // rawData = rawData.replaceFirst(RegExp(r'^(n|\\n)(?=\s*<)'), '');
//               if (rawData.trim().startsWith("n  <")) {
//                 debugPrint("Gotcha ${rawData}");
//                 final firstTagIndex = rawData.indexOf('<');
//                 if (firstTagIndex > 0) {
//                   rawData = rawData.substring(firstTagIndex);
//                 }
//               }
//               rawData = cleanHtmlResponse(rawData);
//               debugPrint("Cleaned stream line $rawData");
//               if (streamResponse.isEmpty) {
//                 String cleaned =
//                 rawData.replaceFirst(RegExp(r'^.*?(?=<div)'), '');
//                 streamResponse.write(cleaned);
//                 var cleanHtml = cleanHtmlResponse(streamResponse.toString());
//                 debugPrint("adding new item");
//                 chatList.add(ChatHelperModel(
//                   userType: UserType.bot,
//                   messageType: MessageType.text,
//                   message: cleanHtml,
//                   chatId: globalChatId.value,
//                   index: chatList.length,
//                   likeStatus: 2,
//                   key: GlobalKey(),
//                 ));
//                 scrollToEnd();
//               } else {
//                 streamResponse.write(rawData);
//                 var cleanHtml = cleanHtmlResponse(streamResponse.toString());
//                 chatList.last.message = cleanHtml;
//                 scrollToEnd();
//                 chatList.refresh();
//               }
//               previousResponse = cleanHtmlResponse(rawData);
//               chatList.refresh();
//             }
//
//             if (line.startsWith("event: TestsourceLinks")) {
//               startCollecting = false;
//               debugPrint("TestSourceLink");
//               testSourceLinkEvent = "TestSourceLinkEvent";
//               continue;
//             }
//             if (testSourceLinkEvent == "TestSourceLinkEvent") {
//               debugPrint("Skiping testSourceLinkEvent");
//               testSourceLinkEvent = "";
//               continue;
//             }
//
//             if (line.startsWith("event: dataDone")) {
//               debugPrint("Data done");
//               startCollecting = false;
//               continue;
//             }
//
//             /// for retrieving chatId
//             if (line.startsWith("event: ChatHistoryId")) {
//               debugPrint("hey hey $line");
//               chatIdEvent = "ChatIdFound";
//               continue;
//             }
//
//             if (chatIdEvent == "ChatIdFound") {
//               final chatId = line.replaceAll('"', '');
//               globalChatId.value = chatId.substring(5).trim();
//               debugPrint("Extracted Chat ID: ${globalChatId.value}");
//               chatIdEvent = "";
//             }
//
//             /// for hyperlinking
//             if (line.startsWith("event: keywords")) {
//               keywordEvent = "KeywordEvent";
//               continue;
//             }
//             if (keywordEvent == "KeywordEvent") {
//               try {
//                 if (line.length < 5) {
//                   debugPrint("Line too short for substring: $line");
//                   keywordEvent = "";
//                   continue;
//                 }
//
//                 final rawData = line.substring(5).trim();
//                 debugPrint("keywords : $rawData");
//
//                 if (rawData.isEmpty) {
//                   debugPrint("rawData is empty. Skipping.");
//                   keywordEvent = "";
//                   // return;
//                   continue;
//                 }
//
//                 dynamic decoded;
//                 try {
//                   decoded = json.decode(rawData);
//                 } catch (e) {
//                   debugPrint("Invalid JSON: $e\nrawData: $rawData");
//                   keywordEvent = "";
//                   continue;
//                 }
//
//                 if (decoded is! List ||
//                     decoded.isEmpty ||
//                     decoded.first is! Map) {
//                   debugPrint("Invalid keyword format. Skipping.");
//                   keywordEvent = "";
//                   continue;
//                 }
//
//                 final List<dynamic> data = decoded;
//                 final keywordLinks =
//                 data.map((item) => KeywordLink.fromJson(item)).toList();
//
//                 for (var item in keywordLinks) {
//                   if (item.url == null || item.url == "") {
//                     debugPrint("empty url");
//                     keywordLinks.remove(item);
//                   }
//                 }
//
//                 keywordMapList = keywordLinks
//                     .map((k) => {"keyword": k.keyword, "url": k.url})
//                     .toList();
//
//                 final newHtml = await hyperlinkKeywordsInHtml(
//                     chatList.last.message, keywordMapList);
//                 chatList.last.message = "";
//                 chatList.last.message = cleanHtmlResponse(newHtml);
//                 chatList.refresh();
//                 keywordEvent = "";
//               } catch (e) {
//                 keywordEvent = "";
//                 debugPrint("Error while fetching keywords: $e");
//                 continue;
//               }
//             }
//
//             ///for shopping banners
//             if (line.startsWith("event: shoppingBannerHtml")) {
//               debugPrint("banner found");
//               shoppingBannerEvent = "ShoppingBannerEvent";
//               continue;
//             }
//
//             if (shoppingBannerEvent == "ShoppingBannerEvent") {
//               // End of shopping banner stream
//               try {
//                 rawData = line.substring(5).trim();
//                 rawData = rawData.replaceAll(RegExp(r'^"+|"+$'), '');
//                 debugPrint("shopping banner $rawData");
//                 rawData = sourceLinkCleaner1(rawData);
//                 debugPrint("shopping banner $rawData");
//                 // if(streamResponse.isEmpty){
//                 String cleaned =
//                 rawData.replaceFirst(RegExp(r'^.*?(?=<div)'), '');
//                 final document = html_parser.parse(rawData);
//                 final adsBlock = document.querySelector('.ai-ads-block');
//                 String? shoppingBannerHtml;
//
//                 if (adsBlock != null) {
//                   shoppingBannerHtml = adsBlock.outerHtml;
//                   adsBlock.remove();
//                 }
//
//                 debugPrint(
//                     "Parsed shopping banner HTML: $shoppingBannerHtml");
//
//                 chatList.last.shoppingBannerHtml = shoppingBannerHtml ?? "";
//                 chatList.refresh();
//               } on Exception catch (e) {
//                 debugPrint("Cannot parse shopping banner");
//                 // TODO
//               }
//               // shoppingBannerBuffer.clear();
//               shoppingBannerEvent = "";
//             }
//
//             /// for followUpQuestions
//             if (line.startsWith("event: followUpQuestions")) {
//               followUpEvent = "FollowUpEvent";
//               continue;
//             }
//             if (followUpEvent == "FollowUpEvent") {
//               rawData = line.substring(5).trim();
//               rawData = rawData.replaceAll(RegExp(r'^"+|"+$'), '');
//               debugPrint("followUp Questions $rawData");
//               if (rawData.isNotEmpty) {
//                 final questions = jsonDecode(rawData) as List<dynamic>;
//                 final followUps = questions.cast<String>();
//
//                 chatList.last.followUpQuestion = followUps;
//                 chatList.refresh();
//               }
//               followUpEvent = "";
//             }
//           }
//         }
//       }
//
//       if (nt <= 2) {
//         if (numberOfTrials > 3) {
//           chatList.removeLast(); // removing current answer
//           chatList.removeLast(); // remove the prompt
//           chatList.refresh();
//           MyToast.myShowToast("Can't Generate Answer");
//           return;
//         } else {
//           numberOfTrials++;
//           debugPrint("number of trials $numberOfTrials");
//           chatList.removeLast();
//           chatList.add(ChatHelperModel(
//             message: '',
//             userType: UserType.bot,
//             isLoading: true,
//             messageType: MessageType.text,
//             chatId: globalChatId.value,
//             index: chatList.isEmpty ? 0 : chatList.length,
//             likeStatus: 2,
//             key: GlobalKey(),
//           ));
//           newCallPrompt(prompt, isRegenerate, isImageGenerated, count + 1);
//           debugPrint("called api again $count time");
//         }
//       }
//     }
//   } catch (e) {
//     debugPrint("Error while generating answer ${e.toString()}");
//   } finally {
//     imageGenerationFlag.value = false;
//     imageEditFlag.value = false;
//     isPromptApiRunning.value = false;
//     isImageGenerating = false;
//     questionController.value.clear();
//     questionFocusNode.value.unfocus();
//     uploadedImagePathList.clear();
//     uploadedImageBase64List.clear();
//     documentUint8ByteList.clear();
//     documentPdfFilePathList.clear();
//     textFieldHint.value = "Ask Anything";
//     selectedImageOption.value = "Image";
//   }
// }
