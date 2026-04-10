import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mobile_app/config/base_config.dart';
import 'package:mobile_app/controller/property_registration_controller.dart';
import 'package:mobile_app/screens/citizen/property_tax/create_applications/property_document_upload_screen.dart';
import 'package:mobile_app/widgets/header_widgets.dart';

class PropertySpecialCategoryScreen extends StatefulWidget {
  const PropertySpecialCategoryScreen({super.key});

  @override
  State<PropertySpecialCategoryScreen> createState() => _PropertySpecialCategoryScreenState();
}

class _PropertySpecialCategoryScreenState extends State<PropertySpecialCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedCategory;
  late final PropertyRegistrationController _propertyController;

  @override
  void initState() {
    super.initState();
    _propertyController = Get.find<PropertyRegistrationController>();
  }

  final List<String> categories = [
    'Not Applicable',
    'Below Poverty Line',
    'Defense Personnel',
    'Freedom Fighter',
    'Handicapped/ Disabled',
    'Widow',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HeaderTop(
        titleWidget: const Text('Property Tax Registration'),
        onPressed: () => Navigator.of(context).pop(),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Special Category *',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Please provide information regarding the owner(s) of the property.',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: BaseConfig.textColor2,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    ...categories.map((category) => Container(
                      margin: EdgeInsets.only(bottom: 12.h),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            selectedCategory = category;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: selectedCategory == category
                                  ? BaseConfig.appThemeColor1
                                  : BaseConfig.borderColor,
                              width: selectedCategory == category ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8.r),
                            color: selectedCategory == category
                                ? BaseConfig.appThemeColor1.withOpacity(0.1)
                                : Colors.transparent,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 20.w,
                                height: 20.h,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selectedCategory == category
                                        ? BaseConfig.appThemeColor1
                                        : BaseConfig.borderColor,
                                    width: 2,
                                  ),
                                  color: selectedCategory == category
                                      ? BaseConfig.appThemeColor1
                                      : Colors.transparent,
                                ),
                                child: selectedCategory == category
                                    ? Icon(
                                        Icons.check,
                                        size: 12.sp,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  '• $category',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: selectedCategory == category
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: selectedCategory == category
                                        ? BaseConfig.appThemeColor1
                                        : BaseConfig.textColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )).toList(),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(16.w),
              child: SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (selectedCategory == null) {
                        Get.snackbar(
                          'Error',
                          'Please select a special category',
                          backgroundColor: BaseConfig.redColor,
                          colorText: Colors.white,
                        );
                        return;
                      }
                      
                      // Save data to controller
                      _propertyController.specialCategory.value = selectedCategory!;
                      
                      Get.to(() => const PropertyDocumentUploadScreen());
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BaseConfig.appThemeColor1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}