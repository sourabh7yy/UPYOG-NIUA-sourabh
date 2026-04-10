import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_app/components/bottom_sheet.dart';
import 'package:mobile_app/config/base_config.dart';
import 'package:mobile_app/controller/auth_controller.dart';
import 'package:mobile_app/controller/file_controller.dart';
import 'package:mobile_app/controller/language_controller.dart';
import 'package:mobile_app/controller/property_registration_controller.dart';
import 'package:mobile_app/screens/citizen/property_tax/create_applications/property_summary_screen.dart';
import 'package:mobile_app/utils/utils.dart';
import 'package:mobile_app/widgets/header_widgets.dart';

class PropertyDocumentUploadScreen extends StatefulWidget {
  const PropertyDocumentUploadScreen({super.key});

  @override
  State<PropertyDocumentUploadScreen> createState() => _PropertyDocumentUploadScreenState();
}

class _PropertyDocumentUploadScreenState extends State<PropertyDocumentUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  late final PropertyRegistrationController _propertyController;
  final _authController = Get.find<AuthController>();
  final _fileController = Get.find<FileController>();
  final _languageController = Get.find<LanguageController>();
  
  String? selectedIdentityDocType;
  String? selectedAddressDocType;
  File? identityFile;
  File? addressFile;
  var disableSubmit = false.obs;

  @override
  void initState() {
    super.initState();
    _propertyController = Get.find<PropertyRegistrationController>();
  }

  final List<Map<String, String>> identityDocTypes = [
    {'code': 'aadhaar', 'name': 'Aadhaar Card'},
    {'code': 'voter', 'name': 'Voter ID'},
    {'code': 'driving', 'name': 'Driving License'},
    {'code': 'pan', 'name': 'PAN Card'},
    {'code': 'passport', 'name': 'Passport'},
  ];

  final List<Map<String, String>> addressDocTypes = [
    {'code': 'electricity', 'name': 'Electricity Bill'},
    {'code': 'water', 'name': 'Water Bill'},
    {'code': 'gas', 'name': 'Gas Bill'},
    {'code': 'voter', 'name': 'Voter ID'},
    {'code': 'driving', 'name': 'Driving License'},
  ];

  Future<void> _pickFile(bool isIdentity) async {
    try {
      openBottomSheet(
        onTabImageGallery: () => _uploadFile(isIdentity, ImageSource.gallery),
        onTabImageCamera: () => _uploadFile(isIdentity, ImageSource.camera),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick file: ${e.toString()}',
        backgroundColor: BaseConfig.redColor,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _uploadFile(bool isIdentity, ImageSource source) async {
    try {
      await _fileController.selectAndPickImage(imageSource: source);
      if (_fileController.imageFile == null) return;

      setState(() {
        disableSubmit.value = true;
      });

      // Get tenant ID for file upload
      final pincode = _propertyController.pincode.value;
      String tenantId = 'pg.citya';
      if (pincode.isNotEmpty) {
        final code = int.tryParse(pincode);
        if (code != null) {
          final tenant = _languageController.mdmsResTenant.tenants
              ?.firstWhereOrNull((tenant) => tenant.pincode?.contains(code) ?? false);
          if (tenant?.code != null) {
            tenantId = tenant!.code!;
          }
        }
      }

      final fileStoreId = await _fileController.postFile(
        token: _authController.token!.accessToken!,
        tenantId: tenantId,
        module: 'property-upload',
        customFileImage: _fileController.imageFile!.path,
        customFileName: _fileController.fileName,
      );

      if (fileStoreId == null) {
        setState(() {
          disableSubmit.value = false;
        });
        Get.snackbar(
          'Error',
          'Failed to upload file',
          backgroundColor: BaseConfig.redColor,
          colorText: Colors.white,
        );
        return;
      }

      setState(() {
        if (isIdentity) {
          identityFile = _fileController.imageFile;
          _propertyController.identityFileStoreId.value = fileStoreId;
        } else {
          addressFile = _fileController.imageFile;
          _propertyController.addressFileStoreId.value = fileStoreId;
        }
        disableSubmit.value = false;
        });

        Get.snackbar(
          'Success',
          'File uploaded successfully',
          backgroundColor: BaseConfig.statusGreenColor,
          colorText: Colors.white,
        );
    } catch (e) {
      setState(() {
        disableSubmit.value = false;
      });
      Get.snackbar(
        'Error',
        'Failed to upload file: ${e.toString()}',
        backgroundColor: BaseConfig.redColor,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildDocumentSection({
    required String title,
    required String description,
    required List<Map<String, String>> docTypes,
    required String? selectedDocType,
    required Function(String?) onDocTypeChanged,
    required File? selectedFile,
    required VoidCallback onFilePick,
    required bool isRequired,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          description,
          style: TextStyle(
            fontSize: 14.sp,
            color: BaseConfig.textColor2,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'File Type: jpg, PNG or PDF (less than 2 MB)',
          style: TextStyle(
            fontSize: 12.sp,
            color: BaseConfig.greyColor3,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          'Document Type ${isRequired ? '*' : ''}',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          value: selectedDocType,
          decoration: InputDecoration(
            hintText: 'Select document type',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 12.h,
            ),
          ),
          items: docTypes.map((type) {
            return DropdownMenuItem(
              value: type['code'],
              child: Text(type['name']!),
            );
          }).toList(),
          onChanged: onDocTypeChanged,
          validator: isRequired ? (value) {
            if (value == null || value.isEmpty) {
              return 'Document type is required';
            }
            return null;
          } : null,
        ),
        SizedBox(height: 16.h),
        InkWell(
          onTap: onFilePick,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              border: Border.all(color: BaseConfig.borderColor),
              borderRadius: BorderRadius.circular(8.r),
              color: BaseConfig.greyColor1.withOpacity(0.1),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 32.sp,
                  color: BaseConfig.appThemeColor1,
                ),
                SizedBox(height: 8.h),
                Text(
                  'Choose File',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: BaseConfig.appThemeColor1,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  selectedFile != null 
                      ? selectedFile.path.split('/').last
                      : 'No file chosen',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: selectedFile != null 
                        ? BaseConfig.textColor 
                        : BaseConfig.greyColor3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
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
                      'Document Upload',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    _buildDocumentSection(
                      title: 'Proof Of Identity *',
                      description: 'Adhaar Card, Voter ID, Driving License',
                      docTypes: identityDocTypes,
                      selectedDocType: selectedIdentityDocType,
                      onDocTypeChanged: (value) {
                        setState(() {
                          selectedIdentityDocType = value;
                        });
                      },
                      selectedFile: identityFile,
                      onFilePick: () => _pickFile(true),
                      isRequired: true,
                    ),
                    SizedBox(height: 32.h),
                    _buildDocumentSection(
                      title: 'Proof of Address *',
                      description: 'Adhaar Card, Voter ID, Driving License',
                      docTypes: addressDocTypes,
                      selectedDocType: selectedAddressDocType,
                      onDocTypeChanged: (value) {
                        setState(() {
                          selectedAddressDocType = value;
                        });
                      },
                      selectedFile: addressFile,
                      onFilePick: () => _pickFile(false),
                      isRequired: true,
                    ),
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
                  onPressed: disableSubmit.value ? null : () {
                    if (_formKey.currentState!.validate()) {
                      if (identityFile == null) {
                        Get.snackbar(
                          'Error',
                          'Please upload proof of identity document',
                          backgroundColor: BaseConfig.redColor,
                          colorText: Colors.white,
                        );
                        return;
                      }
                      if (addressFile == null) {
                        Get.snackbar(
                          'Error',
                          'Please upload proof of address document',
                          backgroundColor: BaseConfig.redColor,
                          colorText: Colors.white,
                        );
                        return;
                      }
                      
                      // Save data to controller
                      _propertyController.identityDocType.value = selectedIdentityDocType ?? '';
                      _propertyController.identityFile.value = identityFile;
                      _propertyController.addressDocType.value = selectedAddressDocType ?? '';
                      _propertyController.addressFile.value = addressFile;
                      
                      Get.to(() => const PropertySummaryScreen());
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