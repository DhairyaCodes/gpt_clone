import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gpt_clone/repositories/chat_repository.dart';

class ChatInputField extends ConsumerStatefulWidget {
  const ChatInputField({
    super.key,
    required this.onSendMessage,
  });

  final Function(String message, {String? imageUrl}) onSendMessage;

  @override
  ConsumerState<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends ConsumerState<ChatInputField> {
  final _controller = TextEditingController();
  String? _imageUrl;
  bool _isUploading = false;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (mounted) {
        setState(() {
          _isTyping = _controller.text.isNotEmpty;
        });
      }
    });
    // widget.focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.trim().isNotEmpty || _imageUrl != null) {
      widget.onSendMessage(_controller.text.trim(), imageUrl: _imageUrl);
      _controller.clear();
      if (mounted) {
        setState(() {
          _imageUrl = null;
        });
      }
    }
  }

  void _showAttachmentSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          color: Theme.of(context).colorScheme.secondary,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSheetOption(
                  icon: Icons.camera_alt_outlined,
                  label: 'Camera',
                  onTap: () => _pickImage(ImageSource.camera)),
              _buildSheetOption(
                  icon: Icons.photo_library_outlined,
                  label: 'Photos',
                  onTap: () => _pickImage(ImageSource.gallery)),
              _buildSheetOption(
                  icon: Icons.folder_copy_outlined, label: 'Files', onTap: () {}),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSheetOption(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 30),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: source);

    if (pickedFile != null) {
      if (mounted) setState(() => _isUploading = true);
      final imageUrl =
          await ref.read(chatRepositoryProvider).uploadImage(pickedFile.path);
      if (mounted) {
        setState(() {
          _imageUrl = imageUrl;
          _isUploading = false;
        });
      }

      if (imageUrl == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image upload failed.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // if(widget.key == const ValueKey('new_chat_key')){
    //   widget.focusNode.requestFocus();
    // }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_imageUrl != null)
          Container(
            alignment: Alignment.centerLeft,
            // margin: const EdgeInsets.only(bottom: 8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Stack(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: screenHeight * 0.2),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 1, // Square box
                      child: Image.network(
                        _imageUrl!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => setState(() => _imageUrl = null),
                    child: Container(
                      decoration: const BoxDecoration(
                          color: Colors.black54, shape: BoxShape.circle),
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 18),
                    ),
                  ),
                )
              ],
            ),
          ),
        Container(
          // height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: _imageUrl == null
                ? BorderRadius.circular(30)
                : BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: _isUploading ? null : _showAttachmentSheet,
                icon: _isUploading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.image_outlined),
              ),
              Expanded(
                child: TextField(
                  // onTapOutside: (event) {
                  //   widget.focusNode.unfocus();
                  // },
                  controller: _controller,
                  decoration: const InputDecoration(
                      hintText: 'Ask anything',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey)),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              if (!_isTyping)
                IconButton(onPressed: () {}, icon: const Icon(Icons.mic_none))
              else
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.arrow_upward),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.onSurface,
                    foregroundColor: Theme.of(context).colorScheme.surface,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
