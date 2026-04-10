import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_app/config/base_config.dart';
import 'package:mobile_app/controller/language_controller.dart';
import 'package:mobile_app/controller/locality_controller.dart';
import 'package:mobile_app/controller/property_registration_controller.dart';
import 'package:mobile_app/screens/citizen/property_tax/create_applications/property_special_category_screen.dart';
import 'package:mobile_app/screens/citizen/property_tax/create_applications/property_owner_screen.dart';
import 'package:mobile_app/widgets/header_widgets.dart';

class PropertyAddressScreen extends StatefulWidget {
  final List<OwnerData> owners;
  final int currentOwnerIndex;
  
  const PropertyAddressScreen({
    super.key,
    required this.owners,
    required this.currentOwnerIndex,
  });

  @override
  State<PropertyAddressScreen> createState() => _PropertyAddressScreenState();
}

class _PropertyAddressScreenState extends State<PropertyAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pincodeController = TextEditingController();
  final _streetController = TextEditingController();
  final _houseNoController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  
  final _localityController = Get.put(LocalityController());
  late final PropertyRegistrationController _propertyController;
  
  String? selectedCity;
  String? selectedLocality;
  bool _isLoadingLocation = false;
  bool _isLoadingCityLocality = false;

  List<String> cities = [];
  List<String> localities = [];

  @override
  void initState() {
    super.initState();
    _propertyController = Get.find<PropertyRegistrationController>();
    
    // Pre-fill data if available for current owner
    final currentOwner = widget.owners[widget.currentOwnerIndex];
    _pincodeController.text = currentOwner.pincodeController.text;
    _streetController.text = currentOwner.streetController.text;
    _houseNoController.text = currentOwner.houseNoController.text;
    _landmarkController.text = currentOwner.landmarkController.text;
    selectedCity = currentOwner.selectedCity;
    selectedLocality = currentOwner.selectedLocality;
  }

  @override
  void dispose() {
    _pincodeController.dispose();
    _streetController.dispose();
    _houseNoController.dispose();
    _landmarkController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _fetchCityAndLocality(String pincode) async {
    if (pincode.length != 6) return;
    
    setState(() {
      _isLoadingCityLocality = true;
    });

    try {
      final code = int.tryParse(pincode);
      if (code == null) {
        setState(() {
          _isLoadingCityLocality = false;
        });
        return;
      }

      // Get language controller for MDMS data
      final languageController = Get.find<LanguageController>();
      
      // Find tenant by pincode from MDMS
      final tenant = languageController.mdmsResTenant.tenants
          ?.firstWhereOrNull((tenant) => tenant.pincode?.contains(code) ?? false);

      if (tenant != null) {
        // Set city data
        selectedCity = tenant.city?.name;
        
        // Fetch locality data
        await _localityController.fetchLocality(
          hierarchyTypeCode: 'ADMIN',
          tenantId: tenant.code!,
        );

        // Find locality by pincode
        final boundaries = _localityController.locality.value?.tenantBoundary;
        if (boundaries != null && boundaries.isNotEmpty) {
          final boundary = boundaries.first.boundary
              ?.firstWhereOrNull((b) => b.pinCode?.contains(code) ?? false);

          if (boundary != null) {
            setState(() {
              localities = [boundary.name!];
              selectedLocality = boundary.name;
              cities = [selectedCity!];
              _isLoadingCityLocality = false;
            });
            
            // Save locality code to controller
            _propertyController.localityCode.value = boundary.code ?? '';
            
            return;
          }
        }
      }

      // If no match found, clear data
      setState(() {
        cities = [];
        localities = [];
        selectedCity = null;
        selectedLocality = null;
        _isLoadingCityLocality = false;
      });

      Get.snackbar(
        'Error',
        'No matching pincode found.',
        backgroundColor: BaseConfig.redColor,
        colorText: Colors.white,
      );
    } catch (e) {
      setState(() {
        _isLoadingCityLocality = false;
      });
      Get.snackbar(
        'Error',
        'Failed to fetch city and locality data',
        backgroundColor: BaseConfig.redColor,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoadingLocation = false;
        });
        Get.snackbar(
          'Error',
          'Location services are disabled. Please enable them.',
          backgroundColor: BaseConfig.redColor,
          colorText: Colors.white,
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoadingLocation = false;
          });
          Get.snackbar(
            'Error',
            'Location permissions are denied',
            backgroundColor: BaseConfig.redColor,
            colorText: Colors.white,
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoadingLocation = false;
        });
        Get.snackbar(
          'Error',
          'Location permissions are permanently denied',
          backgroundColor: BaseConfig.redColor,
          colorText: Colors.white,
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitudeController.text = position.latitude.toString();
        _longitudeController.text = position.longitude.toString();
        _isLoadingLocation = false;
      });

      Get.snackbar(
        'Success',
        'Current location fetched successfully',
        backgroundColor: BaseConfig.statusGreenColor,
        colorText: Colors.white,
      );
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
      Get.snackbar(
        'Error',
        'Failed to get location: ${e.toString()}',
        backgroundColor: BaseConfig.redColor,
        colorText: Colors.white,
      );
    }
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
                      'Address Details - ${widget.owners[widget.currentOwnerIndex].nameController.text}',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.owners.length > 1)
                      Text(
                        'Owner ${widget.currentOwnerIndex + 1} of ${widget.owners.length}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: BaseConfig.appThemeColor1,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    SizedBox(height: 24.h),
                    Text(
                      'Pincode *',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _pincodeController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: InputDecoration(
                        hintText: 'Enter pincode',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 12.h,
                        ),
                      ),
                      onChanged: (value) {
                        if (value.length == 6) {
                          _fetchCityAndLocality(value);
                        }
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Pincode is required';
                        }
                        if (value.length != 6) {
                          return 'Pincode must be 6 digits';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'City *',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    _isLoadingCityLocality
                        ? Container(
                            height: 50.h,
                            decoration: BoxDecoration(
                              border: Border.all(color: BaseConfig.borderColor),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: const Center(child: CircularProgressIndicator()),
                          )
                        : DropdownButtonFormField<String>(
                            value: selectedCity,
                            decoration: InputDecoration(
                              hintText: 'Select city',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 12.h,
                              ),
                            ),
                            items: cities.map((city) {
                              return DropdownMenuItem(
                                value: city,
                                child: Text(city),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedCity = value;
                              });
                            },
                            validator: (value) {
                              // Make city optional for non-first owners if not available
                              if (widget.currentOwnerIndex > 0 && (cities.isEmpty || value == null)) {
                                return null;
                              }
                              if (value == null || value.isEmpty) {
                                return 'City is required';
                              }
                              return null;
                            },
                          ),
                    SizedBox(height: 16.h),
                    Text(
                      'Locality *',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    _isLoadingCityLocality
                        ? Container(
                            height: 50.h,
                            decoration: BoxDecoration(
                              border: Border.all(color: BaseConfig.borderColor),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: const Center(child: CircularProgressIndicator()),
                          )
                        : DropdownButtonFormField<String>(
                            value: selectedLocality,
                            decoration: InputDecoration(
                              hintText: 'Select locality',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 12.h,
                              ),
                            ),
                            items: localities.map((locality) {
                              return DropdownMenuItem(
                                value: locality,
                                child: Text(locality),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedLocality = value;
                              });
                            },
                            validator: (value) {
                              // Make locality optional for non-first owners if not available
                              if (widget.currentOwnerIndex > 0 && (localities.isEmpty || value == null)) {
                                return null;
                              }
                              if (value == null || value.isEmpty) {
                                return 'Locality is required';
                              }
                              return null;
                            },
                          ),
                    SizedBox(height: 16.h),
                    Text(
                      'Street Name *',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _streetController,
                      decoration: InputDecoration(
                        hintText: 'Enter street name',
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
                          return 'Street name is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'House No *',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _houseNoController,
                      decoration: InputDecoration(
                        hintText: 'Enter house number',
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
                          return 'House number is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Landmark',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _landmarkController,
                      decoration: InputDecoration(
                        hintText: 'Enter landmark (optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 12.h,
                        ),
                      ),
                    ),
                    if (widget.currentOwnerIndex == 0) ...[
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Latitude *',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                TextFormField(
                                  controller: _latitudeController,
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(
                                    hintText: 'Latitude',
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
                                      return 'Required';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Longitude *',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                TextFormField(
                                  controller: _longitudeController,
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(
                                    hintText: 'Longitude',
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
                                      return 'Required';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      ElevatedButton.icon(
                        onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                        icon: _isLoadingLocation
                            ? SizedBox(
                                width: 16.w,
                                height: 16.h,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(Icons.my_location, size: 18.sp),
                        label: Text(
                          _isLoadingLocation ? 'Fetching...' : 'Get Current Location',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: BaseConfig.statusGreenColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                    ],
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
                    // Save current owner's address data
                    final currentOwner = widget.owners[widget.currentOwnerIndex];
                    currentOwner.pincodeController.text = _pincodeController.text;
                    currentOwner.streetController.text = _streetController.text;
                    currentOwner.houseNoController.text = _houseNoController.text;
                    currentOwner.landmarkController.text = _landmarkController.text;
                    currentOwner.selectedCity = selectedCity;
                    currentOwner.selectedLocality = selectedLocality;
                    
                    // Update the owner in allOwners with address data
                    if (widget.currentOwnerIndex < _propertyController.allOwners.length) {
                      _propertyController.allOwners[widget.currentOwnerIndex]['permanentAddress'] = 
                          '${_houseNoController.text}, ${_streetController.text}, ${_landmarkController.text}, ${selectedLocality ?? ''}, ${selectedCity ?? ''}, ${_pincodeController.text}';
                      _propertyController.allOwners[widget.currentOwnerIndex]['pincode'] = _pincodeController.text;
                      _propertyController.allOwners[widget.currentOwnerIndex]['city'] = selectedCity ?? '';
                      _propertyController.allOwners[widget.currentOwnerIndex]['locality'] = selectedLocality ?? '';
                      _propertyController.allOwners[widget.currentOwnerIndex]['street'] = _streetController.text;
                      _propertyController.allOwners[widget.currentOwnerIndex]['houseNo'] = _houseNoController.text;
                      _propertyController.allOwners[widget.currentOwnerIndex]['landmark'] = _landmarkController.text;
                    }
                    
                    // ALWAYS save to controller for all ownership types
                    _propertyController.pincode.value = _pincodeController.text;
                    _propertyController.city.value = selectedCity ?? '';
                    _propertyController.locality.value = selectedLocality ?? '';
                    _propertyController.streetName.value = _streetController.text;
                    _propertyController.houseNo.value = _houseNoController.text;
                    _propertyController.landmark.value = _landmarkController.text;
                    if (widget.currentOwnerIndex == 0) {
                      _propertyController.latitude.value = _latitudeController.text;
                      _propertyController.longitude.value = _longitudeController.text;
                    }
                    
                    print('=== ADDRESS SAVED TO CONTROLLER ===');
                    print('currentOwnerIndex: ${widget.currentOwnerIndex}');
                    print('owners.length: ${widget.owners.length}');
                    print('pincode: ${_propertyController.pincode.value}');
                    print('city: ${_propertyController.city.value}');
                    print('locality: ${_propertyController.locality.value}');
                    print('streetName: ${_propertyController.streetName.value}');
                    print('houseNo: ${_propertyController.houseNo.value}');
                    print('landmark: ${_propertyController.landmark.value}');
                    print('===================================');
                    
                    // Check if there are more owners
                    if (widget.currentOwnerIndex < widget.owners.length - 1) {
                      // Navigate to next owner's address
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PropertyAddressScreen(
                            owners: widget.owners,
                            currentOwnerIndex: widget.currentOwnerIndex + 1,
                          ),
                        ),
                      );
                    } else {
                      // All owners completed, go to next screen
                      Get.to(() => const PropertySpecialCategoryScreen());
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
                  widget.currentOwnerIndex < widget.owners.length - 1 ? 'Next Owner' : 'Next',
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