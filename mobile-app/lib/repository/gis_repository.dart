import 'package:mobile_app/model/request/request_info_model.dart';
import 'package:mobile_app/services/base_service.dart';
import 'package:mobile_app/utils/constants/api_constants.dart';
import 'package:mobile_app/utils/enums/app_enums.dart';
import 'package:mobile_app/utils/utils.dart';

class GisRepository {
  static final BaseService _baseService = BaseService();

  static Future<dynamic> searchPT({
    required String token,
    required String tenantId,
    required int fromDate,
    required int toDate,
  }) async {
    final local = await getLocal();
    final response = await _baseService.makeRequest(
      url: Url.GIS_PT_SEARCH,
      method: RequestType.POST,
      body: {
        'tenantId': tenantId,
        'fromDate': fromDate,
        'toDate': toDate,
        'includeBillData': true,
        'businessService': 'PT',
      },
      requestInfo: RequestInfo(authToken: token, local: local),
    );
    return response;
  }
}
