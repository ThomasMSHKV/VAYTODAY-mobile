import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:VayToday/core/theme/app_colors.dart';
import 'package:VayToday/features/addresses/domain/models/address_model.dart';
import 'package:VayToday/features/add_company/presentation/cubit/add_company_cubit.dart';
import 'package:VayToday/features/add_company/presentation/cubit/add_company_state.dart';
import 'package:VayToday/features/add_company/presentation/widgets/add_company_dropdown_field.dart';
import 'package:VayToday/features/add_company/presentation/widgets/add_company_photo_picker.dart';
import 'package:VayToday/features/add_company/presentation/widgets/add_company_text_field.dart';
import 'package:VayToday/features/companies/data/company_management_repository.dart';
import 'package:VayToday/features/home/domain/models/home_category.dart';

class AddCompanyScreen extends StatelessWidget {
  const AddCompanyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddCompanyCubit()..loadFormData(),
      child: const _AddCompanyView(),
    );
  }
}

class _AddCompanyView extends StatefulWidget {
  const _AddCompanyView();

  @override
  State<_AddCompanyView> createState() => _AddCompanyViewState();
}

class _AddCompanyViewState extends State<_AddCompanyView> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _addressFocusNode = FocusNode();
  final _imagePicker = ImagePicker();

  String? _selectedCategoryId;
  String? _selectedServiceId;
  String? _selectedCityId;
  int? _selectedAddressId;
  TimeOfDay? _workStart;
  TimeOfDay? _workEnd;
  final List<String> _imagePaths = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _addressFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddCompanyCubit, AddCompanyState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == AddCompanyStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Компания отправлена на модерацию')),
          );
          Navigator.of(context).pop(true);
        } else if (state.status == AddCompanyStatus.failure &&
            state.errorMessage.isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage)));
        }
      },
      builder: (context, state) {
        final isLoading = state.status == AddCompanyStatus.loading;
        final isSubmitting = state.status == AddCompanyStatus.submitting;
        final selectedCategory = _selectedCategory(state.categories);

        return Scaffold(
          backgroundColor: AppColors.surface,
          body: SafeArea(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(
                      22,
                      18,
                      22,
                      MediaQuery.of(context).viewInsets.bottom + 28,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context),
                        const SizedBox(height: 34),
                        AddCompanyTextField(
                          controller: _titleController,
                          label: 'Название компании',
                          hintText: 'Введите название компании',
                          icon: Icons.business_outlined,
                        ),
                        const SizedBox(height: 28),
                        AddCompanyDropdownField(
                          label: 'Категория',
                          hintText: 'Выберите категорию',
                          icon: Icons.grid_view_rounded,
                          items: state.categories
                              .map(
                                (category) => AddCompanyDropdownOption(
                                  value: category.id.toString(),
                                  label: category.title,
                                ),
                              )
                              .toList(),
                          value: _selectedCategoryId,
                          onChanged: (value) {
                            setState(() {
                              _selectedCategoryId = value;
                              _selectedServiceId = null;
                            });
                          },
                        ),
                        const SizedBox(height: 28),
                        AddCompanyDropdownField(
                          label: 'Подкатегория',
                          hintText: selectedCategory == null
                              ? 'Сначала выберите категорию'
                              : 'Выберите подкатегорию',
                          icon: Icons.local_offer_outlined,
                          items: (selectedCategory?.services ?? const [])
                              .map(
                                (service) => AddCompanyDropdownOption(
                                  value: service.id.toString(),
                                  label: service.name,
                                ),
                              )
                              .toList(),
                          value: _selectedServiceId,
                          onChanged: selectedCategory == null
                              ? null
                              : (value) {
                                  setState(() => _selectedServiceId = value);
                                },
                        ),
                        const SizedBox(height: 28),
                        AddCompanyTextField(
                          controller: _descriptionController,
                          label: 'Описание компании',
                          hintText: 'Расскажите о вашей компании',
                          icon: Icons.description_outlined,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 28),
                        AddCompanyTextField(
                          controller: _phoneController,
                          label: 'Номер телефона',
                          hintText: 'Введите номер телефона',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 28),
                        AddCompanyDropdownField(
                          label: 'Город',
                          hintText: 'Выберите город',
                          icon: Icons.location_city_outlined,
                          items: state.cities
                              .map(
                                (city) => AddCompanyDropdownOption(
                                  value: city.id.toString(),
                                  label: city.name,
                                ),
                              )
                              .toList(),
                          value: _selectedCityId,
                          onChanged: (value) {
                            setState(() => _selectedCityId = value);
                          },
                        ),
                        const SizedBox(height: 28),
                        _buildAddressSearchField(state.addresses),
                        const SizedBox(height: 28),
                        _buildWorkTimeField(context),
                        const SizedBox(height: 28),
                        AddCompanyPhotoPicker(
                          imagePaths: _imagePaths,
                          onTap: _pickImages,
                          onRemove: (index) {
                            setState(() => _imagePaths.removeAt(index));
                          },
                        ),
                        const SizedBox(height: 34),
                        _buildSubmitButton(context, isSubmitting),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  HomeCategory? _selectedCategory(List<HomeCategory> categories) {
    final categoryId = int.tryParse(_selectedCategoryId ?? '');
    if (categoryId == null) return null;

    for (final category in categories) {
      if (category.id == categoryId) return category;
    }

    return null;
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.authText,
            size: 26,
          ),
        ),
        const Expanded(
          child: Center(
            child: Text(
              'Добавление компании',
              style: TextStyle(
                color: AppColors.authText,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildAddressSearchField(List<AddressModel> addresses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Адрес компании',
          style: TextStyle(
            color: AppColors.authText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        RawAutocomplete<AddressModel>(
          textEditingController: _addressController,
          focusNode: _addressFocusNode,
          displayStringForOption: (address) => address.name,
          optionsBuilder: (textEditingValue) {
            final query = textEditingValue.text.trim().toLowerCase();
            if (query.isEmpty) return const Iterable<AddressModel>.empty();

            return addresses
                .where((address) => address.name.toLowerCase().contains(query))
                .take(8);
          },
          onSelected: (address) {
            setState(() {
              _selectedAddressId = address.id;
              _addressController.text = address.name;
            });
          },
          fieldViewBuilder:
              (context, textController, focusNode, onFieldSubmitted) {
                return Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.authGold,
                        size: 26,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: TextField(
                          controller: textController,
                          focusNode: focusNode,
                          cursorColor: AppColors.authGold,
                          onChanged: (value) {
                            final selectedAddress = _selectedAddress(addresses);
                            if (selectedAddress?.name != value &&
                                _selectedAddressId != null) {
                              setState(() => _selectedAddressId = null);
                            }
                          },
                          decoration: const InputDecoration(
                            hintText: 'Начните вводить адрес',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            hintStyle: TextStyle(
                              color: AppColors.textLight,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.search_rounded,
                        color: AppColors.authText,
                        size: 24,
                      ),
                    ],
                  ),
                );
              },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: MediaQuery.of(context).size.width - 44,
                  constraints: const BoxConstraints(maxHeight: 260),
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.14),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: AppColors.border.withValues(alpha: 0.65),
                    ),
                    itemBuilder: (context, index) {
                      final address = options.elementAt(index);
                      return ListTile(
                        dense: true,
                        leading: const Icon(
                          Icons.place_outlined,
                          color: AppColors.detailTextGreen,
                        ),
                        title: Text(
                          address.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.authText,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onTap: () => onSelected(address),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
        if (addresses.isEmpty) ...[
          const SizedBox(height: 8),
          const Text(
            'Список адресов пока пуст',
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        if (_selectedAddressId == null &&
            _addressController.text.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text(
            'Выберите адрес из списка',
            style: TextStyle(
              color: AppColors.moderationPending,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildWorkTimeField(BuildContext context) {
    final value = _workStart == null || _workEnd == null
        ? 'Выберите начало и конец'
        : '${_formatTime(_workStart!)} - ${_formatTime(_workEnd!)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Время работы',
          style: TextStyle(
            color: AppColors.authText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _pickWorkTime(context),
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  color: AppColors.authGold,
                  size: 26,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      color: _workStart == null || _workEnd == null
                          ? AppColors.textLight
                          : AppColors.authText,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.authText,
                  size: 30,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context, bool isSubmitting) {
    return SizedBox(
      height: 64,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isSubmitting ? null : () => _submit(context),
        label: Text(
          isSubmitting ? 'Отправляем...' : 'Добавить компанию',
          style: const TextStyle(
            color: AppColors.authText,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.authGold,
          disabledBackgroundColor: AppColors.authGold,
          elevation: 6,
          shadowColor: Colors.black.withValues(alpha: 0.18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Future<void> _pickWorkTime(BuildContext context) async {
    final start = await showTimePicker(
      context: context,
      initialTime: _workStart ?? const TimeOfDay(hour: 9, minute: 0),
      helpText: 'Начало работы',
    );
    if (start == null || !context.mounted) return;

    final end = await showTimePicker(
      context: context,
      initialTime: _workEnd ?? const TimeOfDay(hour: 21, minute: 0),
      helpText: 'Конец работы',
    );
    if (end == null) return;

    setState(() {
      _workStart = start;
      _workEnd = end;
    });
  }

  Future<void> _pickImages() async {
    final remaining = 4 - _imagePaths.length;
    if (remaining <= 0) {
      _showValidationMessage(context, 'Можно загрузить максимум 4 фото');
      return;
    }

    final images = await _imagePicker.pickMultiImage(imageQuality: 85);
    if (images.isEmpty) return;

    final selected = images.take(remaining).map((image) => image.path);
    setState(() => _imagePaths.addAll(selected));

    if (images.length > remaining && mounted) {
      _showValidationMessage(context, 'Добавлены первые $remaining фото');
    }
  }

  void _submit(BuildContext context) {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final phone = _phoneController.text.trim();
    final addressText = _addressController.text.trim();
    final serviceId = int.tryParse(_selectedServiceId ?? '');
    final cityId = int.tryParse(_selectedCityId ?? '');

    if (title.isEmpty || description.isEmpty) {
      _showValidationMessage(context, 'Заполните название и описание');
      return;
    }
    if (phone.isEmpty) {
      _showValidationMessage(context, 'Заполните номер телефона');
      return;
    }
    if (_selectedCategoryId == null || serviceId == null) {
      _showValidationMessage(context, 'Выберите категорию и подкатегорию');
      return;
    }
    if (cityId == null) {
      _showValidationMessage(context, 'Выберите город');
      return;
    }
    if (addressText.isEmpty || _selectedAddressId == null) {
      _showValidationMessage(context, 'Выберите адрес из списка');
      return;
    }
    if (_workStart == null || _workEnd == null) {
      _showValidationMessage(context, 'Выберите время работы');
      return;
    }

    context.read<AddCompanyCubit>().createCompany(
      CreateCompanyRequest(
        title: title,
        description: description,
        phone: phone,
        serviceId: serviceId,
        cityId: cityId,
        addressId: _selectedAddressId,
        addressText: addressText,
        workStart: _formatTime(_workStart!),
        workEnd: _formatTime(_workEnd!),
        imagePaths: List.unmodifiable(_imagePaths),
      ),
    );
  }

  AddressModel? _selectedAddress(List<AddressModel> addresses) {
    final selectedId = _selectedAddressId;
    if (selectedId == null) return null;

    for (final address in addresses) {
      if (address.id == selectedId) return address;
    }

    return null;
  }

  String _formatTime(TimeOfDay value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _showValidationMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
