import 'package:get/get.dart';
import 'package:mobile_app/model/employee/gis_model/gis_pt_model.dart';
import 'package:mobile_app/repository/gis_repository.dart';
import 'package:mobile_app/utils/errors/error_handler.dart';
import 'package:mobile_app/utils/utils.dart';

class GisController extends GetxController {
  RxList<GisPtFeature> features = <GisPtFeature>[].obs;
  RxBool isLoading = false.obs;

  Future<void> fetchPtProperties({
    required String token,
    required String tenantId,
  }) async {
    try {
      isLoading.value = true;
      dPrint('GIS API: Calling searchPT → tenantId: $tenantId, token: $token');
      final now = DateTime.now();
      final fromDate = DateTime(now.year - 1).millisecondsSinceEpoch;
      final toDate = now.millisecondsSinceEpoch;
      dPrint('GIS API: fromDate: $fromDate, toDate: $toDate');

      final res = await GisRepository.searchPT(
        token: token,
        tenantId: tenantId,
        fromDate: fromDate,
        toDate: toDate,
      );

      dPrint('GIS API: Response received → $res');
      final response = GisPtResponse.fromJson(res);
      features.assignAll(response.features);
      dPrint('GIS API: Total features parsed: ${features.length}');
    } catch (e, s) {
      dPrint('GIS API Error: $e');
      ErrorHandler.allExceptionsHandler(e, s);
    } finally {
      isLoading.value = false;
    }
  }
}
