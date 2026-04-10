import 'dart:io';
import 'package:get/get.dart';

class PropertyRegistrationController extends GetxController {
  // Property Details
  var propertyType = ''.obs;
  var structureType = ''.obs;
  var propertyAge = ''.obs;
  var electricityNumber = ''.obs;
  var uniqueId = ''.obs;
  var areaSqft = ''.obs;

  // Floor Details
  var basement = ''.obs;
  var floors = ''.obs;
  var groundFloor = ''.obs;
  var unitUsageType = ''.obs;
  var subUsageType = ''.obs;
  var occupancy = ''.obs;
  var builtUpArea = ''.obs;

  // Address Details
  var pincode = ''.obs;
  var city = ''.obs;
  var locality = ''.obs;
  var localityCode = ''.obs;
  var streetName = ''.obs;
  var houseNo = ''.obs;
  var landmark = ''.obs;
  var latitude = ''.obs;
  var longitude = ''.obs;
  var tenantId = ''.obs;

  // Owner Details
  var ownershipType = ''.obs;
  var ownerName = ''.obs;
  var gender = ''.obs;
  var mobileNumber = ''.obs;
  var guardian = ''.obs;
  var relationship = ''.obs;
  var email = ''.obs;
  
  // Multiple owners data
  var allOwners = <Map<String, dynamic>>[].obs;

  // Special Category
  var specialCategory = ''.obs;

  // Documents
  var identityDocType = ''.obs;
  var addressDocType = ''.obs;
  Rx<File?> identityFile = Rx<File?>(null);
  Rx<File?> addressFile = Rx<File?>(null);
  var identityFileStoreId = ''.obs;
  var addressFileStoreId = ''.obs;

  void clearAll() {
    propertyType.value = '';
    structureType.value = '';
    propertyAge.value = '';
    electricityNumber.value = '';
    uniqueId.value = '';
    areaSqft.value = '';
    basement.value = '';
    floors.value = '';
    groundFloor.value = '';
    unitUsageType.value = '';
    subUsageType.value = '';
    occupancy.value = '';
    builtUpArea.value = '';
    pincode.value = '';
    city.value = '';
    locality.value = '';
    localityCode.value = '';
    streetName.value = '';
    houseNo.value = '';
    landmark.value = '';
    latitude.value = '';
    longitude.value = '';
    tenantId.value = '';
    ownershipType.value = '';
    ownerName.value = '';
    gender.value = '';
    mobileNumber.value = '';
    guardian.value = '';
    relationship.value = '';
    email.value = '';
    allOwners.clear();
    specialCategory.value = '';
    identityDocType.value = '';
    addressDocType.value = '';
    identityFile.value = null;
    addressFile.value = null;
    identityFileStoreId.value = '';
    addressFileStoreId.value = '';
  }
}