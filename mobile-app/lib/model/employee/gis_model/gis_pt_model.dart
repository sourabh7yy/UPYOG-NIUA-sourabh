class GisPtResponse {
  final int? totalCount;
  final List<GisPtFeature> features;

  GisPtResponse({this.totalCount, required this.features});

  factory GisPtResponse.fromJson(Map<String, dynamic> json) {
    final featureList = (json['geoJsonData']?['features'] as List? ?? [])
        .map((e) => GisPtFeature.fromJson(e))
        .where((f) => f.lat != 0.0 && f.lng != 0.0)
        .toList();

    return GisPtResponse(
      totalCount: json['totalCount'],
      features: featureList,
    );
  }
}

class GisPtFeature {
  final double lat;
  final double lng;
  final String id;
  final String? propertyType;
  final String? usageCategory;
  final String? paymentStatus;
  final String? status;
  final String? landArea;
  final String? tenantId;

  GisPtFeature({
    required this.lat,
    required this.lng,
    required this.id,
    this.propertyType,
    this.usageCategory,
    this.paymentStatus,
    this.status,
    this.landArea,
    this.tenantId,
  });

  factory GisPtFeature.fromJson(Map<String, dynamic> json) {
    final coords = json['geometry']?['coordinates'] as List? ?? [0.0, 0.0];
    final props = json['properties'] as Map<String, dynamic>? ?? {};
    return GisPtFeature(
      lng: (coords[0] as num).toDouble(),
      lat: (coords[1] as num).toDouble(),
      id: json['id'] ?? '',
      propertyType: props['propertyType'],
      usageCategory: props['usageCategory'],
      paymentStatus: props['paymentStatus'],
      status: props['status'],
      landArea: props['landArea'],
      tenantId: props['tenantId'],
    );
  }
}
