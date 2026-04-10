import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mobile_app/config/base_config.dart';
import 'package:mobile_app/controller/property_registration_controller.dart';
import 'package:mobile_app/screens/citizen/property_tax/create_applications/property_intermediate_screen.dart';
import 'package:mobile_app/widgets/header_widgets.dart';

class PropertyFloorsScreen extends StatefulWidget {
  final String selectedPropertyType;
  final String electricityNumber;
  final String uniqueId;
  final String area;

  const PropertyFloorsScreen({
    super.key,
    required this.selectedPropertyType,
    required this.electricityNumber,
    required this.uniqueId,
    required this.area,
  });

  @override
  State<PropertyFloorsScreen> createState() => _PropertyFloorsScreenState();
}

class _PropertyFloorsScreenState extends State<PropertyFloorsScreen> {
  String? selectedBasement;
  String? selectedFloors;
  final _formKey = GlobalKey<FormState>();
  late final PropertyRegistrationController _propertyController;

  final List<String> basementOptions = ['0', '1', '2', '3', '4', '5'];
  final List<String> floorOptions = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];

  @override
  void initState() {
    super.initState();
    _propertyController = Get.find<PropertyRegistrationController>();
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
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Property Details',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'No of Basement *',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    DropdownButtonFormField<String>(
                      value: selectedBasement,
                      decoration: InputDecoration(
                        hintText: 'Select number of basements',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 12.h,
                        ),
                      ),
                      items: basementOptions.map((value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedBasement = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Number of basements is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 32.h),
                    Text(
                      'No of Floors *',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    DropdownButtonFormField<String>(
                      value: selectedFloors,
                      decoration: InputDecoration(
                        hintText: 'Select number of floors',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 12.h,
                        ),
                      ),
                      items: floorOptions.map((value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedFloors = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Number of floors is required';
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
                    _propertyController.basement.value = selectedBasement!;
                    _propertyController.floors.value = selectedFloors!;
                    
                    Get.to(() => PropertyIntermediateScreen(
                      selectedPropertyType: widget.selectedPropertyType,
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
