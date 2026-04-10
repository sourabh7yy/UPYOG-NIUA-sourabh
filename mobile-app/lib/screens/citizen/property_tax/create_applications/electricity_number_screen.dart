import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mobile_app/config/base_config.dart';
import 'package:mobile_app/controller/property_registration_controller.dart';
import 'package:mobile_app/screens/citizen/property_tax/create_applications/property_floors_screen.dart';
import 'package:mobile_app/widgets/header_widgets.dart';

class ElectricityNumberScreen extends StatefulWidget {
  final String selectedPropertyType;
  
  const ElectricityNumberScreen({
    super.key,
    required this.selectedPropertyType,
  });

  @override
  State<ElectricityNumberScreen> createState() => _ElectricityNumberScreenState();
}

class _ElectricityNumberScreenState extends State<ElectricityNumberScreen> {
  final _electricityNumberController = TextEditingController();
  final _uniqueIdController = TextEditingController();
  final _areaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late final PropertyRegistrationController _propertyController;

  @override
  void initState() {
    super.initState();
    _propertyController = Get.find<PropertyRegistrationController>();
  }

  @override
  void dispose() {
    _electricityNumberController.dispose();
    _uniqueIdController.dispose();
    _areaController.dispose();
    super.dispose();
  }

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
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Electricity No',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Property Type: ${widget.selectedPropertyType}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'Electricity No *',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _electricityNumberController,
                      decoration: InputDecoration(
                        hintText: 'Enter electricity number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 12.h,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Electricity number is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'Unique ID *',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _uniqueIdController,
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      decoration: InputDecoration(
                        hintText: 'Enter unique ID (max 10 digits)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 12.h,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Unique ID is required';
                        }
                        if (value.length > 10) {
                          return 'Unique ID must be 10 digits or less';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Area (sqft) *',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _areaController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Enter area in sqft',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 12.h,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Area is required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Save data to controller
                    _propertyController.electricityNumber.value = _electricityNumberController.text;
                    _propertyController.uniqueId.value = _uniqueIdController.text;
                    _propertyController.areaSqft.value = _areaController.text;
                    
                    Get.to(() => PropertyFloorsScreen(
                      selectedPropertyType: widget.selectedPropertyType,
                      electricityNumber: _electricityNumberController.text,
                      uniqueId: _uniqueIdController.text,
                      area: _areaController.text,
                    ));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: BaseConfig.appThemeColor1,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'Next',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
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