import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mobile_app/config/base_config.dart';
import 'package:mobile_app/controller/auth_controller.dart';
import 'package:mobile_app/controller/properties_tax_controller.dart';
import 'package:mobile_app/utils/constants/i18_key_constants.dart';
import 'package:mobile_app/utils/enums/modules.dart';
import 'package:mobile_app/utils/extension/extension.dart';
import 'package:mobile_app/utils/utils.dart';
import 'package:mobile_app/widgets/header_widgets.dart';

class CreatePropertyApplication extends StatefulWidget {
  const CreatePropertyApplication({super.key});

  @override
  State<CreatePropertyApplication> createState() => _CreatePropertyApplicationState();
}

class _CreatePropertyApplicationState extends State<CreatePropertyApplication> {
  final AuthController _authController = Get.find<AuthController>();
  final _propertiesTaxController = Get.find<PropertiesTaxController>();
  final _formKey = GlobalKey<FormState>();
  
  final _propertyIdController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _mobileController = TextEditingController();
  
  @override
  void dispose() {
    _propertyIdController.dispose();
    _ownerNameController.dispose();
    _addressController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HeaderTop(
        titleWidget: Text(
          getLocalizedString(
            i18.propertyTax.CREATE_PROPERTY,
            module: Modules.PT,
          ),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        controller: _propertyIdController,
                        label: getLocalizedString(i18.propertyTax.PROPERTY_ID, module: Modules.PT),
                        hint: 'Enter Property ID',
                        isRequired: true,
                      ),
                      SizedBox(height: 16.h),
                      _buildTextField(
                        controller: _ownerNameController,
                        label: getLocalizedString(i18.propertyTax.OWNER_NAME, module: Modules.PT),
                        hint: 'Enter Owner Name',
                        isRequired: true,
                      ),
                      SizedBox(height: 16.h),
                      _buildTextField(
                        controller: _addressController,
                        label: getLocalizedString(i18.propertyTax.ADDRESS, module: Modules.PT),
                        hint: 'Enter Property Address',
                        isRequired: true,
                        maxLines: 3,
                      ),
                      SizedBox(height: 16.h),
                      _buildTextField(
                        controller: _mobileController,
                        label: getLocalizedString(i18.propertyTax.MOBILE_NUMBER, module: Modules.PT),
                        hint: 'Enter Mobile Number',
                        isRequired: true,
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                ),
              ),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isRequired = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label + (isRequired ? ' *' : ''),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 12.h,
            ),
          ),
          validator: isRequired
              ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '$label is required';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: BaseConfig.appThemeColor1,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: Text(
          getLocalizedString(i18.propertyTax.CREATE_PROPERTY, module: Modules.PT),
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement property creation logic
      showSnackBar(
        context,
        'Property creation functionality to be implemented',
        isSuccess: true,
      );
    }
  }
}
