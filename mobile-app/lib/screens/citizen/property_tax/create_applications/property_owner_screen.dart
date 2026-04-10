import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mobile_app/config/base_config.dart';
import 'package:mobile_app/controller/property_registration_controller.dart';
import 'package:mobile_app/screens/citizen/property_tax/create_applications/property_address_screen.dart';
import 'package:mobile_app/screens/citizen/property_tax/create_applications/property_special_category_screen.dart';
import 'package:mobile_app/widgets/header_widgets.dart';

class OwnerData {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController guardianController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController houseNoController = TextEditingController();
  final TextEditingController landmarkController = TextEditingController();
  String? selectedGender;
  String? selectedRelationship;
  String? selectedCity;
  String? selectedLocality;

  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    guardianController.dispose();
    emailController.dispose();
    pincodeController.dispose();
    streetController.dispose();
    houseNoController.dispose();
    landmarkController.dispose();
  }
}

class PropertyOwnerScreen extends StatefulWidget {
  const PropertyOwnerScreen({super.key});

  @override
  State<PropertyOwnerScreen> createState() => _PropertyOwnerScreenState();
}

class _PropertyOwnerScreenState extends State<PropertyOwnerScreen> {
  final _formKey = GlobalKey<FormState>();
  late final PropertyRegistrationController _propertyController;

  String? selectedOwnership;
  List<OwnerData> owners = [OwnerData()];
  
  // Institution fields
  final TextEditingController institutionNameController = TextEditingController();
  final TextEditingController authorizedPersonController = TextEditingController();
  final TextEditingController designationController = TextEditingController();
  final TextEditingController institutionMobileController = TextEditingController();
  final TextEditingController telephoneController = TextEditingController();
  final TextEditingController institutionEmailController = TextEditingController();
  String? selectedInstitutionType;

  @override
  void initState() {
    super.initState();
    _propertyController = Get.find<PropertyRegistrationController>();
  }

  void _addOwner() {
    setState(() {
      owners.add(OwnerData());
    });
  }

  void _removeOwner(int index) {
    if (owners.length > 1) {
      setState(() {
        owners[index].dispose();
        owners.removeAt(index);
      });
    }
  }

  Widget _buildInstitutionForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Institution Details *',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: BaseConfig.appThemeColor1,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Please provide information regarding the owner(s) of the property.',
          style: TextStyle(
            fontSize: 14.sp,
            color: BaseConfig.greyColor3,
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          'Institution Name *',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: institutionNameController,
          decoration: InputDecoration(
            hintText: 'Enter institution name',
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
              return 'Institution name is required';
            }
            return null;
          },
        ),
        SizedBox(height: 16.h),
        Text(
          'Type of Institution *',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          value: selectedInstitutionType,
          decoration: InputDecoration(
            hintText: 'Select institution type',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 12.h,
            ),
          ),
          items: (selectedOwnership == 'government' 
              ? governmentInstitutionTypes 
              : privateInstitutionTypes).map((type) {
            return DropdownMenuItem(
              value: type['code'],
              child: Text(type['name']!),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedInstitutionType = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Institution type is required';
            }
            return null;
          },
        ),
        SizedBox(height: 24.h),
        Text(
          'Authorized Person\'s Details',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: BaseConfig.appThemeColor1,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          'Owner Name *',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: authorizedPersonController,
          decoration: InputDecoration(
            hintText: 'Enter authorized person name',
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
              return 'Authorized person name is required';
            }
            return null;
          },
        ),
        SizedBox(height: 16.h),
        Text(
          'Designation *',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: designationController,
          decoration: InputDecoration(
            hintText: 'Enter designation',
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
              return 'Designation is required';
            }
            return null;
          },
        ),
        SizedBox(height: 16.h),
        Text(
          'Mobile Number *',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: institutionMobileController,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          decoration: InputDecoration(
            hintText: 'Enter mobile number',
            prefixText: '+91 ',
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
              return 'Mobile number is required';
            }
            if (value.length != 10) {
              return 'Mobile number must be 10 digits';
            }
            return null;
          },
        ),
        SizedBox(height: 16.h),
        Text(
          'Alternate Contact Number *',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: telephoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: 'Enter alternate contact number',
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
              return 'Alternate contact number is required';
            }
            return null;
          },
        ),
        SizedBox(height: 16.h),
        Text(
          'Email ID *',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: institutionEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Enter email address',
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
              return 'Email is required';
            }
            if (!GetUtils.isEmail(value)) {
              return 'Enter a valid email address';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildOwnerForm(OwnerData owner, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (index > 0 || selectedOwnership == 'multiple')
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Owner ${index + 1}',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: BaseConfig.appThemeColor1,
                ),
              ),
              if (index > 0)
                IconButton(
                  onPressed: () => _removeOwner(index),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
            ],
          ),
        if (index > 0) SizedBox(height: 16.h),
        Text(
          'Owner Name *',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: owner.nameController,
          decoration: InputDecoration(
            hintText: 'Enter owner name',
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
              return 'Owner name is required';
            }
            return null;
          },
        ),
        SizedBox(height: 16.h),
        Text(
          'Gender *',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          value: owner.selectedGender,
          decoration: InputDecoration(
            hintText: 'Select gender',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 12.h,
            ),
          ),
          items: genderTypes.map((type) {
            return DropdownMenuItem(
              value: type['code'],
              child: Text(type['name']!),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              owner.selectedGender = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Gender is required';
            }
            return null;
          },
        ),
        SizedBox(height: 16.h),
        Text(
          'Mobile Number *',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: owner.mobileController,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          decoration: InputDecoration(
            hintText: 'Enter mobile number',
            prefixText: '+91 ',
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
              return 'Mobile number is required';
            }
            if (value.length != 10) {
              return 'Mobile number must be 10 digits';
            }
            return null;
          },
        ),
        SizedBox(height: 16.h),
        Text(
          'Guardian *',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: owner.guardianController,
          decoration: InputDecoration(
            hintText: 'Enter guardian name',
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
              return 'Guardian name is required';
            }
            return null;
          },
        ),
        SizedBox(height: 16.h),
        Text(
          'Relationship *',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          value: owner.selectedRelationship,
          decoration: InputDecoration(
            hintText: 'Select relationship',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 12.h,
            ),
          ),
          items: relationshipTypes.map((type) {
            return DropdownMenuItem(
              value: type['code'],
              child: Text(type['name']!),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              owner.selectedRelationship = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Relationship is required';
            }
            return null;
          },
        ),
        SizedBox(height: 16.h),
        Text(
          'Email ID',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: owner.emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Enter email address (optional)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 12.h,
            ),
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (!GetUtils.isEmail(value)) {
                return 'Enter a valid email address';
              }
            }
            return null;
          },
        ),
        if (index < owners.length - 1 || selectedOwnership == 'multiple')
          SizedBox(height: 32.h),
      ],
    );
  }

  final List<Map<String, String>> ownershipTypes = [
    {'code': 'single', 'name': 'Single Owner'},
    {'code': 'multiple', 'name': 'Multiple Owners'},
    {'code': 'government', 'name': 'Government Organisation'},
    {'code': 'private', 'name': 'Private Organisation'},
  ];

  final List<Map<String, String>> privateInstitutionTypes = [
    {'code': 'NGO', 'name': 'NGO'},
    {'code': 'OTHERS', 'name': 'Others - Private Institution'},
    {'code': 'PRIVATEBOARD', 'name': 'Private Board'},
    {'code': 'PRIVATECOMPANY', 'name': 'Private Company'},
    {'code': 'PRIVATETRUST', 'name': 'Private Trust/Society'},
  ];

  final List<Map<String, String>> governmentInstitutionTypes = [
    {'code': 'CENTRALGOVERNMENT', 'name': 'Central Government'},
    {'code': 'OTHERSGOVERNMENT', 'name': 'Others - Government Institution'},
    {'code': 'STATEGOVERNMENT', 'name': 'State Government'},
    {'code': 'ULBGOVERNMENT', 'name': 'ULB Government'},
  ];

  final List<Map<String, String>> genderTypes = [
    {'code': 'male', 'name': 'Male'},
    {'code': 'female', 'name': 'Female'},
    {'code': 'transgender', 'name': 'Transgender'},
  ];

  final List<Map<String, String>> relationshipTypes = [
    {'code': 'husband', 'name': 'Husband'},
    {'code': 'father', 'name': 'Father'},
  ];

  @override
  void dispose() {
    for (var owner in owners) {
      owner.dispose();
    }
    institutionNameController.dispose();
    authorizedPersonController.dispose();
    designationController.dispose();
    institutionMobileController.dispose();
    telephoneController.dispose();
    institutionEmailController.dispose();
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
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Owner Details *',
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
                        color: BaseConfig.greyColor3,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'Property\'s Ownership',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Provide Ownership details *',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Choose the type of ownership of the property from the options given below.',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: BaseConfig.greyColor3,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    DropdownButtonFormField<String>(
                      value: selectedOwnership,
                      decoration: InputDecoration(
                        hintText: 'Select ownership type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 12.h,
                        ),
                      ),
                      items: ownershipTypes.map((type) {
                        return DropdownMenuItem(
                          value: type['code'],
                          child: Text(type['name']!),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedOwnership = value;
                          if (value != 'multiple' && owners.length > 1) {
                            for (int i = owners.length - 1; i > 0; i--) {
                              owners[i].dispose();
                            }
                            owners = [owners[0]];
                          }
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ownership type is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 32.h),
                    if (selectedOwnership == 'private' || selectedOwnership == 'government')
                      _buildInstitutionForm()
                    else if (selectedOwnership != null)
                      ...owners.asMap().entries.map((entry) {
                        int index = entry.key;
                        OwnerData owner = entry.value;
                        return _buildOwnerForm(owner, index);
                      }).toList(),
                    if (selectedOwnership == 'multiple')
                      Padding(
                        padding: EdgeInsets.only(top: 16.h),
                        child: OutlinedButton.icon(
                          onPressed: _addOwner,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Another Owner'),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
                          ),
                        ),
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
                    _propertyController.ownershipType.value = selectedOwnership ?? '';
                    
                    if (selectedOwnership == 'private' || selectedOwnership == 'government') {
                      _propertyController.allOwners.clear();
                      _propertyController.allOwners.add({
                        'name': authorizedPersonController.text,
                        'mobileNumber': institutionMobileController.text,
                        'email': institutionEmailController.text,
                        'institutionName': institutionNameController.text,
                        'institutionType': selectedInstitutionType ?? '',
                        'designation': designationController.text,
                        'telephone': telephoneController.text,
                        'ownerSequence': 0,
                      });
                      
                      // Navigate to address screen for institutional ownership
                      final institutionOwner = OwnerData();
                      institutionOwner.nameController.text = authorizedPersonController.text;
                      institutionOwner.mobileController.text = institutionMobileController.text;
                      institutionOwner.emailController.text = institutionEmailController.text;
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PropertyAddressScreen(
                            owners: [institutionOwner],
                            currentOwnerIndex: 0,
                          ),
                        ),
                      );
                      return;
                    } else {
                      _propertyController.allOwners.clear();
                      for (int i = 0; i < owners.length; i++) {
                        final owner = owners[i];
                        _propertyController.allOwners.add({
                          'name': owner.nameController.text,
                          'gender': owner.selectedGender ?? '',
                          'mobileNumber': owner.mobileController.text,
                          'guardian': owner.guardianController.text,
                          'relationship': owner.selectedRelationship ?? '',
                          'email': owner.emailController.text,
                          'ownerSequence': i,
                        });
                      }
                      
                      if (owners.isNotEmpty) {
                        _propertyController.ownerName.value = owners[0].nameController.text;
                        _propertyController.gender.value = owners[0].selectedGender ?? '';
                        _propertyController.mobileNumber.value = owners[0].mobileController.text;
                        _propertyController.guardian.value = owners[0].guardianController.text;
                        _propertyController.relationship.value = owners[0].selectedRelationship ?? '';
                        _propertyController.email.value = owners[0].emailController.text;
                      }
                      
                      // Navigate to address screen for single/multiple owners
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PropertyAddressScreen(
                            owners: owners,
                            currentOwnerIndex: 0,
                          ),
                        ),
                      );
                    }
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
