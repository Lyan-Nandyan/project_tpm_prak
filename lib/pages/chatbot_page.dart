import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage(this.text, {required this.isUser});
}

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final String _apiKey = 'AIzaSyCblmyODRVKZ_zFqU_LfFu6BOBdRArMQ3Q';

  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  GenerativeModel? _model;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
      systemInstruction: Content.text(
          "namamu adalah botopem alias bot tpm(teknologi pemrograman mobile)"
          "anda adalah ahli film, arahkan user agar tetap pada topik perfileman, dan jika dia bertanya tentang rekomendasi, langsung berikan aja rekomendasi 5 film sesuai pertanyaanya"
          "jika user melenceng dari topik film, coba kamu arahkan pelan pelan agar tetap pada topik film, akan tetapi jika dia tetep ngeyel kamu marahin dia gapapa dengan kata kasar"),
    );

    _messages.add(ChatMessage(
      "halo aku adalah ahli perfilman, silahkan tanyakan apa aja terkait dengan film. namaku adalah botepem",
      isUser: false,
    ));
  }

  Future<void> _sendMessage() async {
    final userInput = _textController.text.trim();
    if (userInput.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(userInput, isUser: true));
      _isLoading = true;
    });
    _textController.clear();
    _scrollToBottom();

    try {
      final response = await _model!.generateContent([Content.text(userInput)]);
      final aiResponse =
          response.text ?? "Maaf, saya tidak bisa merespon saat ini.";

      setState(() {
        _messages.add(ChatMessage(aiResponse, isUser: false));
      });
    } catch (e) {
      setState(() {
        _messages.add(
            ChatMessage("Terjadi kesalahan: ${e.toString()}", isUser: false));
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie Chatbot'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message.isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 14),
                    decoration: BoxDecoration(
                      color:
                          message.isUser ? Colors.blueGrey : Colors.grey[800],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      message.text,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(
                backgroundColor: Colors.grey,
              ),
            ),
          _buildChatInput(),
        ],
      ),
    );
  }

  // Widget untuk input teks dan tombol kirim
  Widget _buildChatInput() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              onSubmitted: _isLoading ? null : (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: 'Tanya seputar film...',
                filled: true,
                fillColor: Colors.grey[850],
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.send, size: 28),
            onPressed: _isLoading ? null : _sendMessage,
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(15),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
