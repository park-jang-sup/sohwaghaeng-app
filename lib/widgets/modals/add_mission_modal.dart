import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:b612_1/models/custom_tag.dart';
import 'package:b612_1/widgets/tag_selection_button.dart';

// .tsx의 onAddMission 콜백에서 전달하는 데이터 구조
class NewMissionData {
  final String title;
  final String description;
  final String tagId; // .tsx의 'tag'
  final bool isPublic;

  NewMissionData({
    required this.title,
    required this.description,
    required this.tagId,
    required this.isPublic,
  });
}

// --- .tsx의 defaultTagOptions와 customIconOptions 데이터 ---
final List<CustomTag> _defaultTagOptions = [
  const CustomTag(id: 'wellness', label: '웰빙', icon: LucideIcons.sun),
  const CustomTag(id: 'daily', label: '일상', icon: LucideIcons.coffee),
  const CustomTag(id: 'growth', label: '성장', icon: LucideIcons.book),
  const CustomTag(id: 'happiness', label: '행복', icon: LucideIcons.smile),
  const CustomTag(id: 'love', label: '사랑', icon: LucideIcons.heart),
  const CustomTag(id: 'goal', label: '목표', icon: LucideIcons.target),
  const CustomTag(id: 'energy', label: '에너지', icon: LucideIcons.zap),
  const CustomTag(id: 'achievement', label: '성취', icon: LucideIcons.star),
  const CustomTag(id: 'nature', label: '자연', icon: LucideIcons.treePine),
];

final Map<String, IconData> _customIconOptions = {
  'heart': LucideIcons.heart,
  'star': LucideIcons.star,
  'target': LucideIcons.target,
  'zap': LucideIcons.zap,
  'tree': LucideIcons.treePine,
};
// --- 데이터 끝 ---


class AddMissionModal extends StatefulWidget {
  // .tsx의 Props
  final List<CustomTag> customTags;
  final Function(NewMissionData) onAddMission;
  final Function(CustomTag) onAddCustomTag;

  const AddMissionModal({
    super.key,
    required this.customTags,
    required this.onAddMission,
    required this.onAddCustomTag,
  });

  @override
  State<AddMissionModal> createState() => _AddMissionModalState();
}

class _AddMissionModalState extends State<AddMissionModal> {
  // --- .tsx의 useState에 해당하는 상태 변수 ---
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _customTagNameController = TextEditingController();

  String _selectedTagId = 'wellness';
  bool _isPublic = false;
  bool _showCustomTagForm = false;
  String _selectedCustomIconId = 'heart';
  bool _isTitleEmpty = true;
  bool _isCustomTagEmpty = true;

  late List<CustomTag> _allTags;

  @override
  void initState() {
    super.initState();
    _allTags = [..._defaultTagOptions, ...widget.customTags];

    _titleController.addListener(() {
      setState(() {
        _isTitleEmpty = _titleController.text.trim().isEmpty;
      });
    });
    _customTagNameController.addListener(() {
      setState(() {
        _isCustomTagEmpty = _customTagNameController.text.trim().isEmpty;
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _customTagNameController.dispose();
    super.dispose();
  }

  // .tsx의 handleSubmit
  void _handleSubmit() {
    if (_isTitleEmpty) return;

    widget.onAddMission(NewMissionData(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      tagId: _selectedTagId,
      isPublic: _isPublic,
    ));

    // 폼 초기화 및 모달 닫기 (onClose)
    _resetForm();
    Navigator.pop(context);
  }

  // .tsx의 handleAddCustomTag
  void _handleAddCustomTag() {
    if (_isCustomTagEmpty) return;

    final newTag = CustomTag(
      id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
      label: _customTagNameController.text.trim(),
      icon: _customIconOptions[_selectedCustomIconId] ?? LucideIcons.heart,
    );

    widget.onAddCustomTag(newTag);

    setState(() {
      _allTags.add(newTag);
      _selectedTagId = newTag.id;
      _showCustomTagForm = false;
      _customTagNameController.clear();
      _selectedCustomIconId = 'heart';
    });
  }

  // .tsx의 handleClose
  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    _customTagNameController.clear();
    setState(() {
      _selectedTagId = 'wellness';
      _isPublic = false;
      _showCustomTagForm = false;
      _selectedCustomIconId = 'heart';
    });
  }

  @override
  Widget build(BuildContext context) {
    // .tsx의 <SheetContent>에 해당하는 부분
    // `h-[80vh]` -> 화면 높이의 80%
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // .tsx의 <SheetHeader>
          Text(
            '새로운 미션 추가',
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            '오늘의 소확행을 추가해보세요',
            style: TextStyle(fontSize: 16.0, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24.0),

          // .tsx의 <form> (Flutter에서는 Column/ListView로 대체)
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Title Input ---
                  _buildTextField(
                    controller: _titleController,
                    label: '미션 제목',
                    placeholder: '예: 아침에 따뜻한 차 한 잔 마시기',
                  ),
                  const SizedBox(height: 24.0),

                  // --- Description Input ---
                  _buildTextField(
                    controller: _descriptionController,
                    label: '한 줄 설명',
                    placeholder: '미션에 대한 간단한 설명을 입력해주세요',
                  ),
                  const SizedBox(height: 24.0),

                  // --- Tag Selection ---
                  _buildTagSection(context),
                  const SizedBox(height: 24.0),

                  // --- Public/Private Toggle ---
                  _buildPublicToggle(context),
                  const SizedBox(height: 32.0),

                  // --- Submit Button ---
                  ElevatedButton(
                    onPressed: _isTitleEmpty ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: const Text('미션 추가하기'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 텍스트 입력 필드
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 8.0),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: placeholder,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
            ),
          ),
        ),
      ],
    );
  }

  /// 태그 선택 섹션
  Widget _buildTagSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '성향 태그',
              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500, color: Colors.grey.shade700),
            ),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _showCustomTagForm = !_showCustomTagForm;
                });
              },
              icon: const Icon(LucideIcons.plus, size: 12.0),
              label: const Text('태그 추가', style: TextStyle(fontSize: 12.0)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12.0),

        // --- Custom Tag Form ---
        AnimatedCrossFade(
          firstChild: _buildCustomTagForm(context),
          secondChild: const SizedBox.shrink(),
          crossFadeState: _showCustomTagForm
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 300),
        ),

        // --- Tag Grid ---
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.0,
            mainAxisSpacing: 12.0,
            childAspectRatio: 3.5,
          ),
          itemCount: _allTags.length,
          itemBuilder: (context, index) {
            final tag = _allTags[index];
            return TagSelectionButton(
              label: tag.label,
              icon: tag.icon,
              isSelected: _selectedTagId == tag.id,
              onPressed: () {
                setState(() {
                  _selectedTagId = tag.id;
                });
              },
            );
          },
        ),
      ],
    );
  }

  /// 커스텀 태그 추가 폼
  Widget _buildCustomTagForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _customTagNameController,
                  decoration: InputDecoration(
                    hintText: '새 태그 이름',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              ElevatedButton(
                onPressed: _isCustomTagEmpty ? null : _handleAddCustomTag,
                child: const Text('추가'),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _customIconOptions.entries.map((entry) {
              final isSelected = _selectedCustomIconId == entry.key;
              return IconButton(
                icon: Icon(entry.value),
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade500,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade200,
                    width: 2.0,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _selectedCustomIconId = entry.key;
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// 공개/비공개 토글
  Widget _buildPublicToggle(BuildContext context) {
    // Flutter의 `SwitchListTile`이 .tsx의 UI와 가장 유사
    return SwitchListTile(
      value: _isPublic,
      onChanged: (bool value) {
        setState(() {
          _isPublic = value;
        });
      },
      title: const Text('공개 설정'),
      subtitle: Text(
        _isPublic ? '다른 사용자들과 미션을 공유합니다' : '나만 볼 수 있는 개인 미션입니다',
        style: TextStyle(color: Colors.grey.shade600, fontSize: 12.0),
      ),
      activeColor: Theme.of(context).primaryColor,
      tileColor: Colors.grey.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
    );
  }
}