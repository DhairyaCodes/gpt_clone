import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gpt_clone/repositories/chat_repository.dart';

class ChatInputField extends ConsumerStatefulWidget {
  const ChatInputField({
    super.key,
    required this.onSendMessage,
  });

  final Function({required String message, required List<String> imageUrls})
      onSendMessage;

  @override
  ConsumerState<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends ConsumerState<ChatInputField> {
  final _controller = TextEditingController();
  List<String> _imageUrls = [];
  bool _isUploading = false;
  bool _isTyping = false;
  final FocusNode _focusNode = FocusNode();

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
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.trim().isNotEmpty || _imageUrls.isNotEmpty) {
      widget.onSendMessage(
        message: _controller.text.trim(),
        imageUrls: _imageUrls,
      );
      _controller.clear();
      if (mounted) {
        setState(() {
          _imageUrls = [];
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
                  onTap: () => _pickImages(isCamera: true)),
              _buildSheetOption(
                  icon: Icons.photo_library_outlined,
                  label: 'Photos',
                  onTap: () => _pickImages()),
              _buildSheetOption(
                  icon: Icons.folder_copy_outlined,
                  label: 'Files',
                  onTap: () {}),
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

  Future<void> _pickImages({bool isCamera = false}) async {
    final imagePicker = ImagePicker();

    List<XFile> pickedFiles = [];

    if (isCamera) {
      final file = await imagePicker.pickImage(source: ImageSource.camera);

      if (file != null) {
        pickedFiles.add(file);
      }
    } else {
      pickedFiles = await imagePicker.pickMultiImage();
    }

    if (pickedFiles.isNotEmpty) {
      if (mounted) setState(() => _isUploading = true);

      final imagePaths = pickedFiles.map((file) => file.path).toList();
      final imageUrls =
          await ref.read(chatRepositoryProvider).uploadImages(imagePaths);

      if (mounted) {
        setState(() {
          _imageUrls.addAll(imageUrls);
          _isUploading = false;
        });

        Future.delayed(Duration(milliseconds: 100), () {
          if (mounted) _focusNode.requestFocus();
        });
        // _focusNode.requestFocus();
      }

      if (imageUrls.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image upload failed.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_imageUrls.isNotEmpty)
          Container(
            height: screenHeight * 0.18,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _imageUrls.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final url = _imageUrls[index];
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        url,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _imageUrls.removeAt(index);
                          });
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: _imageUrls.isEmpty
                ? BorderRadius.circular(30)
                : const BorderRadius.only(
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
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.image_outlined),
              ),
              Expanded(
                child: TextField(
                  focusNode: _focusNode,
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Ask anything',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                  onTapOutside: (event) {
                    _focusNode.unfocus();
                  },
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
