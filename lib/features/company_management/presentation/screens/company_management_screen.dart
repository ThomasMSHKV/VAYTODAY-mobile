import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:VayToday/core/theme/app_colors.dart';
import 'package:VayToday/features/add_company/presentation/widgets/add_company_text_field.dart';
import 'package:VayToday/features/companies/data/company_management_repository.dart';
import 'package:VayToday/features/companies/domain/models/company_model.dart';
import 'package:VayToday/features/products/data/products_repository.dart';
import 'package:VayToday/features/products/domain/models/product_model.dart';

class CompanyManagementScreen extends StatefulWidget {
  final CompanyModel company;

  const CompanyManagementScreen({super.key, required this.company});

  @override
  State<CompanyManagementScreen> createState() =>
      _CompanyManagementScreenState();
}

class _CompanyManagementScreenState extends State<CompanyManagementScreen> {
  final _companyRepository = CompanyManagementRepository();
  final _productsRepository = ProductsRepository();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  late CompanyModel _company;
  late Future<List<ProductModel>> _productsFuture;
  TimeOfDay? _workStart;
  TimeOfDay? _workEnd;
  bool _isSavingCompany = false;
  bool _isDeletingCompany = false;

  @override
  void initState() {
    super.initState();
    _company = widget.company;
    _fillCompanyFields(_company);
    _productsFuture = _productsRepository.getProductsByCompanyId(_company.id);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _fillCompanyFields(CompanyModel company) {
    _titleController.text = company.title;
    _descriptionController.text = company.description;
    _phoneController.text = company.phones;
    _addressController.text = company.displayAddress == 'Адрес пока не указан'
        ? ''
        : company.displayAddress;
    _workStart = _parseTime(company.workStart);
    _workEnd = _parseTime(company.workEnd);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
              const SizedBox(height: 26),
              _buildCompanyStatus(),
              const SizedBox(height: 26),
              _buildCompanyForm(),
              const SizedBox(height: 34),
              _buildProductsHeader(),
              const SizedBox(height: 14),
              _buildProductsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(_company),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.authText,
            size: 24,
          ),
        ),
        const Expanded(
          child: Text(
            'Управление компанией',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.authText,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildCompanyStatus() {
    final color = _company.isActive
        ? AppColors.moderationApproved
        : AppColors.moderationPending;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.companyCardBackground,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text(
            _company.isActive ? 'Компания одобрена' : 'Компания в обработке',
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyForm() {
    return Column(
      children: [
        AddCompanyTextField(
          controller: _titleController,
          label: 'Название компании',
          hintText: 'Введите название компании',
          icon: Icons.business_outlined,
        ),
        const SizedBox(height: 22),
        AddCompanyTextField(
          controller: _descriptionController,
          label: 'Описание компании',
          hintText: 'Расскажите о компании',
          icon: Icons.description_outlined,
          maxLines: 4,
        ),
        const SizedBox(height: 22),
        AddCompanyTextField(
          controller: _phoneController,
          label: 'Номер телефона',
          hintText: 'Введите номер телефона',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 22),
        AddCompanyTextField(
          controller: _addressController,
          label: 'Адрес компании',
          hintText: 'Введите адрес компании',
          icon: Icons.location_on_outlined,
        ),
        const SizedBox(height: 22),
        _buildWorkTimeField(),
        const SizedBox(height: 26),
        SizedBox(
          height: 58,
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isSavingCompany ? null : _saveCompany,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.authGold,
              disabledBackgroundColor: AppColors.authGold.withValues(
                alpha: 0.65,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: _isSavingCompany
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(
                    Icons.check_rounded,
                    color: AppColors.detailTextGreen,
                  ),
            label: Text(
              _isSavingCompany ? 'Сохраняем...' : 'Сохранить изменения',
              style: const TextStyle(
                color: AppColors.detailTextGreen,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 50,
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isDeletingCompany ? null : _confirmDeleteCompany,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red, width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: _isDeletingCompany
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete_outline_rounded, size: 20),
            label: Text(
              _isDeletingCompany ? 'Удаляем...' : 'Удалить компанию',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkTimeField() {
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
          onTap: _pickWorkTime,
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

  Widget _buildProductsHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Продукты',
            style: TextStyle(
              color: AppColors.authText,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        FilledButton.icon(
          onPressed: () => _openProductSheet(),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.detailTextGreen,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          icon: const Icon(Icons.add_rounded, size: 20),
          label: const Text(
            'Добавить',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }

  Widget _buildProductsList() {
    return FutureBuilder<List<ProductModel>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 28),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final products = snapshot.data ?? const [];
        if (products.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.companyCardBackground,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              'У компании пока нет продуктов',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final product = products[index];
            return _ProductCard(
              product: product,
              onTap: () => _openProductSheet(product: product),
            );
          },
        );
      },
    );
  }

  Future<void> _pickWorkTime() async {
    final start = await showTimePicker(
      context: context,
      initialTime: _workStart ?? const TimeOfDay(hour: 9, minute: 0),
      helpText: 'Начало работы',
    );
    if (start == null || !mounted) return;

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

  Future<void> _saveCompany() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();

    if (title.isEmpty ||
        description.isEmpty ||
        phone.isEmpty ||
        address.isEmpty) {
      _showMessage('Заполните название, описание, телефон и адрес');
      return;
    }
    if (_workStart == null || _workEnd == null) {
      _showMessage('Выберите время работы');
      return;
    }

    setState(() => _isSavingCompany = true);
    try {
      final updated = await _companyRepository.updateCompany(
        UpdateCompanyRequest(
          company: _company,
          title: title,
          description: description,
          phone: phone,
          addressText: address,
          workStart: _formatTime(_workStart!),
          workEnd: _formatTime(_workEnd!),
        ),
      );
      if (!mounted) return;
      setState(() => _company = updated);
      _showMessage('Компания обновлена');
    } catch (error) {
      if (!mounted) return;
      _showMessage(
        error is CompanyManagementException
            ? error.message
            : 'Не удалось обновить компанию',
      );
    } finally {
      if (mounted) setState(() => _isSavingCompany = false);
    }
  }

  Future<void> _confirmDeleteCompany() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Удалить компанию?',
            style: TextStyle(
              color: AppColors.authText,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'Все ваши данные, ассортимент и отзывы исчезнут, вы уверены что хотите удалить компанию?',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.detailTextGreen,
              ),
              child: const Text(
                'Отмена',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text(
                'Удалить',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _deleteCompany();
    }
  }

  Future<void> _deleteCompany() async {
    setState(() => _isDeletingCompany = true);
    try {
      await _companyRepository.deleteCompany(_company.id);

      if (!mounted) return;

      _showMessage('Компания удалена');
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      _showMessage(
        error is CompanyManagementException
            ? error.message
            : 'Не удалось удалить компанию',
      );
    } finally {
      if (mounted) setState(() => _isDeletingCompany = false);
    }
  }

  Future<void> _openProductSheet({ProductModel? product}) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.screenBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => _ProductFormSheet(
        companyId: _company.id,
        product: product,
        repository: _productsRepository,
      ),
    );

    if (saved == true && mounted) {
      setState(() {
        _productsFuture = _productsRepository.getProductsByCompanyId(
          _company.id,
        );
      });
    }
  }

  TimeOfDay? _parseTime(String value) {
    final parts = value.split(':');
    if (parts.length < 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;

    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTime(TimeOfDay value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const _ProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.companyCardBackground,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.detailLightGreen,
                  borderRadius: BorderRadius.circular(14),
                ),
                clipBehavior: Clip.antiAlias,
                child: product.imageUrl.isEmpty
                    ? const Icon(
                        Icons.inventory_2_outlined,
                        color: AppColors.detailTextGreen,
                      )
                    : Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.image_outlined,
                            color: AppColors.detailTextGreen,
                          );
                        },
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.authText,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.price.isEmpty ? 'Цена не указана' : product.price,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.edit_rounded, color: AppColors.detailTextGreen),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductFormSheet extends StatefulWidget {
  final int companyId;
  final ProductModel? product;
  final ProductsRepository repository;

  const _ProductFormSheet({
    required this.companyId,
    required this.repository,
    this.product,
  });

  @override
  State<_ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<_ProductFormSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _oldPriceController = TextEditingController();
  final _imagePicker = ImagePicker();
  String? _selectedImagePath;
  bool _deleteExistingImage = false;
  bool _isOnDiscountAd = false;
  bool _isSaving = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    if (product != null) {
      _titleController.text = product.title;
      _descriptionController.text = product.description;
      _priceController.text = product.price;
      _oldPriceController.text = product.oldPrice;
      _isOnDiscountAd = product.isOnDiscountAd;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _oldPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        22,
        18,
        22,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 46,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              isEditing ? 'Редактировать продукт' : 'Добавить продукт',
              style: const TextStyle(
                color: AppColors.authText,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 22),
            AddCompanyTextField(
              controller: _titleController,
              label: 'Название',
              hintText: 'Введите название продукта',
              icon: Icons.inventory_2_outlined,
            ),
            const SizedBox(height: 18),
            AddCompanyTextField(
              controller: _descriptionController,
              label: 'Описание',
              hintText: 'Описание продукта',
              icon: Icons.description_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 18),
            AddCompanyTextField(
              controller: _priceController,
              label: 'Цена',
              hintText: 'Например: 1500',
              icon: Icons.payments_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 18),
            AddCompanyTextField(
              controller: _oldPriceController,
              label: 'Старая цена',
              hintText: 'Можно оставить пустым',
              icon: Icons.local_offer_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildProductImagePicker(),
            const SizedBox(height: 16),
            SwitchListTile.adaptive(
              value: _isOnDiscountAd,
              onChanged: (value) => setState(() => _isOnDiscountAd = value),
              contentPadding: EdgeInsets.zero,
              activeThumbColor: AppColors.detailTextGreen,
              activeTrackColor: AppColors.detailTextGreen.withValues(
                alpha: 0.28,
              ),
              title: const Text(
                'Показывать как скидку',
                style: TextStyle(
                  color: AppColors.authText,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 58,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.authGold,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  _isSaving ? 'Сохраняем...' : 'Сохранить продукт',
                  style: const TextStyle(
                    color: AppColors.detailTextGreen,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            if (isEditing) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isSaving || _isDeleting
                      ? null
                      : _confirmDeleteProduct,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: _isDeleting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.delete_outline_rounded, size: 20),
                  label: Text(
                    _isDeleting ? 'Удаляем...' : 'Удалить продукт',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteProduct() async {
    final product = widget.product;
    if (product == null || _isDeleting) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Удалить продукт?',
            style: TextStyle(
              color: AppColors.authText,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'Продукт исчезнет из ассортимента компании. Вы уверены?',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.detailTextGreen,
              ),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) return;

    setState(() => _isDeleting = true);
    try {
      await widget.repository.deleteProduct(product.id);

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      _showMessage(
        error is ProductApiException
            ? error.message
            : 'Не удалось удалить продукт',
      );
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  Future<void> _saveProduct() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final price = _priceController.text.trim();

    if (title.isEmpty || description.isEmpty || price.isEmpty) {
      _showMessage('Заполните название, описание и цену');
      return;
    }

    setState(() => _isSaving = true);
    final request = ProductSaveRequest(
      companyId: widget.companyId,
      title: title,
      description: description,
      price: price,
      oldPrice: _oldPriceController.text.trim(),
      isOnDiscountAd: _isOnDiscountAd,
    );

    try {
      final product = widget.product;
      late final ProductModel savedProduct;
      if (product == null) {
        savedProduct = await widget.repository.createProduct(request);
      } else {
        savedProduct = await widget.repository.updateProduct(
          product.id,
          request,
        );
      }

      await _saveProductImageChanges(savedProduct.id);

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      _showMessage(
        error is ProductApiException
            ? error.message
            : 'Не удалось сохранить продукт',
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildProductImagePicker() {
    final existingImage = _existingImage();
    final hasSelectedImage = _selectedImagePath != null;
    final showExistingImage =
        existingImage != null && !_deleteExistingImage && !hasSelectedImage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Фото продукта',
          style: TextStyle(
            color: AppColors.authText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _pickProductImage,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            height: 118,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (hasSelectedImage)
                  Image.file(File(_selectedImagePath!), fit: BoxFit.cover)
                else if (showExistingImage)
                  Image.network(
                    existingImage.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildImagePlaceholder();
                    },
                  )
                else
                  _buildImagePlaceholder(),
                if (hasSelectedImage || showExistingImage)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: _removeProductImage,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: AppColors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Можно добавить одно фото. Поле необязательное.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          color: AppColors.authGold,
          size: 34,
        ),
        SizedBox(height: 8),
        Text(
          'Добавить фото',
          style: TextStyle(
            color: AppColors.authText,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Future<void> _pickProductImage() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null) return;

    setState(() {
      _selectedImagePath = image.path;
      _deleteExistingImage = false;
    });
  }

  void _removeProductImage() {
    setState(() {
      _selectedImagePath = null;
      _deleteExistingImage = _existingImage() != null;
    });
  }

  Future<void> _saveProductImageChanges(int productId) async {
    final existingImage = _existingImage();
    final selectedImagePath = _selectedImagePath;

    if (selectedImagePath != null) {
      await widget.repository.saveProductImage(
        productId: productId,
        imagePath: selectedImagePath,
        imageId: existingImage?.id,
      );
      return;
    }

    if (_deleteExistingImage && existingImage != null) {
      await widget.repository.deleteProductImage(existingImage.id);
    }
  }

  ProductImageModel? _existingImage() {
    final images = widget.product?.images ?? const [];
    if (images.isEmpty) return null;
    return images.first;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
