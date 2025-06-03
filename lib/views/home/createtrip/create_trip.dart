import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../../../../controller/emoji_controller.dart';
import '../../../../widgets/emoji_selector.dart';
import '../../../widgets/my_textfield.dart';

class Participant {
  final String id;
  TextEditingController nameController;
  TextEditingController membersController;
  bool isCurrentUser;

  Participant({
    required this.id,
    required this.nameController,
    required this.membersController,
    this.isCurrentUser = false,
  });
}

class CreateTrip extends StatefulWidget {
  const CreateTrip({super.key});

  @override
  _CreateTripState createState() => _CreateTripState();
}

class _CreateTripState extends State<CreateTrip> {
  final _formKey = GlobalKey<FormState>();
  final _addParticipantFormKey = GlobalKey<FormState>();
  final TextEditingController _tripNameController = TextEditingController();
  final TextEditingController _newParticipantNameController = TextEditingController();
  final TextEditingController _newParticipantMembersController = TextEditingController();
  String? _selectedCurrency;
  final EmojiController emojiController = Get.put(EmojiController());
  final List<Participant> _participants = [
    Participant(
      nameController: TextEditingController(text: 'Viren'),
      membersController: TextEditingController(text: '1'),
      isCurrentUser: true,
      id: '1',
    ),
  ];
  // Reactive variables to track field states
  final RxBool _isNameValid = false.obs;
  final RxBool _isMembersValid = false.obs;

  @override
  void initState() {
    super.initState();
    // Add listeners to update the reactive variables
    _newParticipantNameController.addListener(() {
      _isNameValid.value = _newParticipantNameController.text.trim().isNotEmpty;
    });
    _newParticipantMembersController.addListener(() {
      final members = _newParticipantMembersController.text.trim();
      _isMembersValid.value = members.isNotEmpty && int.tryParse(members) != null && int.parse(members) > 0;
    });
  }

  @override
  void dispose() {
    _tripNameController.dispose();
    _newParticipantNameController.dispose();
    _newParticipantMembersController.dispose();
    for (var participant in _participants) {
      participant.nameController.dispose();
      participant.membersController.dispose();
    }
    super.dispose();
  }

  void _addParticipant() {
    if (_addParticipantFormKey.currentState!.validate()) {
      setState(() {
        _participants.add(
          Participant(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            nameController: TextEditingController(
              text: _newParticipantNameController.text,
            ),
            membersController: TextEditingController(
              text: _newParticipantMembersController.text,
            ),
          ),
        );
        _newParticipantNameController.clear();
        _newParticipantMembersController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Participant added successfully',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      });
    }
  }

  void _removeParticipant(int index) {
    setState(() {
      final removedParticipant = _participants[index];
      _participants[index].nameController.dispose();
      _participants[index].membersController.dispose();
      _participants.removeAt(index);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${removedParticipant.nameController.text.isNotEmpty ? removedParticipant.nameController.text : 'Participant'} removed',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onInverseSurface,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          action: SnackBarAction(
            label: 'Undo',
            textColor: Theme.of(context).colorScheme.primary,
            onPressed: () {
              setState(() {
                _participants.insert(
                  index,
                  Participant(
                    id: removedParticipant.id,
                    nameController: TextEditingController(
                      text: removedParticipant.nameController.text,
                    ),
                    membersController: TextEditingController(
                      text: removedParticipant.membersController.text,
                    ),
                    isCurrentUser: removedParticipant.isCurrentUser,
                  ),
                );
              });
            },
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final tripData = {
        'tripName': _tripNameController.text,
        'emoji': emojiController.selectedEmoji.value?.char ?? '😊',
        'currency': _selectedCurrency ?? 'USD',
        'participants': _participants
            .map(
              (p) => {
            'name': p.nameController.text,
            'members': int.tryParse(p.membersController.text) ?? 1,
            'isCurrentUser': p.isCurrentUser,
          },
        )
            .toList(),
      };
      print('Trip Data: $tripData');
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.primary,
          content: Text(
            'Trip created successfully!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Stack(
          children: [
            Text(
              'New Trip',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.1),
              ),
            ),
            Text('New Trip', style: theme.textTheme.headlineSmall),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withOpacity(0.1),
                            theme.colorScheme.secondary.withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.onSurface.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Obx(
                                  () => GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => Dialog(
                                      backgroundColor: theme.cardTheme.color,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const EmojiSelectorBottomSheet(),
                                    ),
                                  );
                                },
                                child: CircleAvatar(
                                  backgroundColor: theme.cardTheme.color,
                                  radius: 24,
                                  child: Text(
                                    emojiController.selectedEmoji.value?.char ??
                                        '😊',
                                    style: const TextStyle(fontSize: 24),
                                    semanticsLabel: 'Select trip emoji',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Title',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  CustomTextField(
                                    hintText: 'Enter trip name',
                                    controller: _tripNameController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a trip name';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Currency', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    DropdownButtonFormField2<String>(
                      decoration: InputDecoration(
                        icon: Icon(
                          Icons.currency_exchange,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        contentPadding:
                        const EdgeInsets.symmetric(vertical: 14),
                      ),
                      hint: Text(
                        'Select currency',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      items: ['USD', 'EUR', 'GBP', 'JPY', 'INR']
                          .map(
                            (currency) => DropdownMenuItem(
                          value: currency,
                          child: Text(
                            currency,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                      )
                          .toList(),
                      value: _selectedCurrency,
                      onChanged: (value) {
                        setState(() {
                          _selectedCurrency = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a currency';
                        }
                        return null;
                      },
                      dropdownStyleData: DropdownStyleData(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: theme.cardTheme.color,
                        ),
                        elevation: 1,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Participants', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Form(
                      key: _addParticipantFormKey,
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: theme.colorScheme.primary.withOpacity(0.2),
                          ),
                        ),
                        color: theme.colorScheme.surface,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: theme.colorScheme.primaryContainer,
                                child: Text(
                                  _newParticipantNameController.text.isNotEmpty
                                      ? _newParticipantNameController.text[0]
                                      .toUpperCase()
                                      : '?',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 3,
                                child: CustomTextField(
                                  border: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: theme.colorScheme.primary,
                                      width: 1,
                                    ),
                                  ),
                                  hintText: 'Enter name',
                                  controller: _newParticipantNameController,
                                  TextInputAction: TextInputAction.next,
                                  validator: (value) =>
                                  value == null || value.trim().isEmpty
                                      ? 'Name required'
                                      : null,
                                  onFieldSubmitted: (_) {
                                    FocusScope.of(context).nextFocus();
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: CustomTextField(
                                  border: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: theme.colorScheme.primary,
                                      width: 1,
                                    ),
                                  ),
                                  hintText: 'Members',
                                  controller: _newParticipantMembersController,
                                  keyboardType: TextInputType.number,
                                  TextInputAction: TextInputAction.done,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Number required';
                                    }
                                    final num = int.tryParse(value);
                                    if (num == null || num <= 0) {
                                      return 'Valid number needed';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              Obx(
                                    () => IconButton(
                                  icon: Icon(
                                    Icons.add_circle,
                                    color: _isNameValid.value && _isMembersValid.value
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.primary.withOpacity(0.3),
                                    size: 24,
                                  ),
                                  onPressed: _isNameValid.value && _isMembersValid.value
                                      ? _addParticipant
                                      : null,
                                  splashRadius: 20,
                                  tooltip: 'Add participant',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final participant = _participants[index];
                return AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    child: Card(
                      elevation: participant.isCurrentUser ? 1 : 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: participant.isCurrentUser
                            ? BorderSide(
                          color:
                          theme.colorScheme.primary.withOpacity(0.3),
                        )
                            : BorderSide.none,
                      ),
                      color: index % 2 == 0
                          ? theme.colorScheme.surface
                          : theme.colorScheme.surfaceVariant.withOpacity(0.95),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: participant.isCurrentUser
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.primaryContainer,
                              child: Text(
                                participant.nameController.text.isNotEmpty
                                    ? participant.nameController.text[0]
                                    .toUpperCase()
                                    : '?',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: participant.isCurrentUser
                                      ? theme.colorScheme.onPrimary
                                      : theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 3,
                              child: CustomTextField(
                                border: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.primary,
                                    width: 1,
                                  ),
                                ),
                                hintText: 'Enter name',
                                controller: participant.nameController,
                                TextInputAction: TextInputAction.next,
                                validator: (value) =>
                                value == null || value.isEmpty
                                    ? 'Name required'
                                    : null,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context).nextFocus();
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: CustomTextField(
                                border: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.primary,
                                    width: 1,
                                  ),
                                ),
                                hintText: 'Members',
                                controller: participant.membersController,
                                keyboardType: TextInputType.number,
                                TextInputAction: TextInputAction.done,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Number required';
                                  }
                                  final num = int.tryParse(value);
                                  if (num == null || num <= 0) {
                                    return 'Valid number needed';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            if (!participant.isCurrentUser)
                              IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: theme.colorScheme.error,
                                  size: 24,
                                ),
                                onPressed: () => _removeParticipant(index),
                                splashRadius: 20,
                                tooltip: 'Delete this participant',
                              ),
                            if (participant.isCurrentUser)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Me',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  semanticsLabel: 'Current user',
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              childCount: _participants.length,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    splashFactory: NoSplash.splashFactory,
                    elevation: 0,
                  ).copyWith(
                    backgroundColor:
                    MaterialStateProperty.all(Colors.transparent),
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'Create Trip',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        semanticsLabel: 'Create trip',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CreateTripState(tripName: ${_tripNameController.text}, participants: ${_participants.length})';
  }
}