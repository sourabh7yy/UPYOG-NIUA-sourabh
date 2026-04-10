import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_app/config/base_config.dart';
import 'package:mobile_app/controller/auth_controller.dart';
import 'package:mobile_app/controller/gis_controller.dart';
import 'package:mobile_app/model/employee/gis_model/gis_pt_model.dart';
import 'package:mobile_app/utils/utils.dart';
import 'package:mobile_app/widgets/header_widgets.dart';
import 'package:mobile_app/widgets/small_text.dart';

class GisMapScreen extends StatefulWidget {
  final String? tenantId;
  const GisMapScreen({super.key, this.tenantId});

  @override
  State<GisMapScreen> createState() => _GisMapScreenState();
}

class _GisMapScreenState extends State<GisMapScreen> {
  final _gisController = Get.put(GisController());
  final _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final tenantId = widget.tenantId ?? await _getTenantId();
    dPrint('GIS MAP: Loading properties for tenantId: $tenantId');
    await _gisController.fetchPtProperties(
      token: _authController.token!.accessToken!,
      tenantId: tenantId,
    );
  }

  Future<String> _getTenantId() async {
    final city = await getCityTenant();
    return city.code ?? BaseConfig.STATE_TENANT_ID;
  }

  void _showPropertyInfo(GisPtFeature feature) {
    dPrint('GIS MAP: Marker tapped → ID: ${feature.id}, lat: ${feature.lat}, lng: ${feature.lng}');
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SmallTextNotoSans(
              text: 'ID: ${feature.id}',
              fontWeight: FontWeight.w600,
              color: BaseConfig.textColor,
            ),
            SizedBox(height: 8.h),
            SmallTextNotoSans(text: 'Type: ${feature.propertyType ?? 'N/A'}'),
            SmallTextNotoSans(text: 'Usage: ${feature.usageCategory ?? 'N/A'}'),
            SmallTextNotoSans(text: 'Land Area: ${feature.landArea ?? 'N/A'} sq.ft'),
            SmallTextNotoSans(
              text: 'Payment: ${feature.paymentStatus ?? 'N/A'}',
              color: feature.paymentStatus == 'PAID'
                  ? BaseConfig.statusResolvedColor
                  : BaseConfig.statusRejectedColor,
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HeaderTop(
        title: 'Property Map',
        onPressed: () => Navigator.of(context).pop(),
      ),
      body: Obx(() {
        if (_gisController.isLoading.value) {
          return showCircularIndicator();
        }

        final features = _gisController.features;

        return Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: features.isNotEmpty
                    ? LatLng(features.first.lat, features.first.lng)
                    : const LatLng(28.6139, 77.2090),
                initialZoom: 12,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.mobile_app',
                ),
                MarkerLayer(
                  markers: features
                      .map(
                        (f) => Marker(
                          point: LatLng(f.lat, f.lng),
                          width: 36,
                          height: 36,
                          child: GestureDetector(
                            onTap: () => _showPropertyInfo(f),
                            child: const Icon(
                              Icons.location_pin,
                              color: BaseConfig.appThemeColor1,
                              size: 36,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: BaseConfig.mainBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                child: SmallTextNotoSans(
                  text: '${features.length} Properties',
                  fontWeight: FontWeight.w600,
                  color: BaseConfig.textColor,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
