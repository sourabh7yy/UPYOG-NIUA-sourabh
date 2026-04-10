import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mobile_app/components/documents_not_found/documents_not_found.dart';
import 'package:mobile_app/components/error_page/network_error.dart';
import 'package:mobile_app/config/base_config.dart';
import 'package:mobile_app/controller/auth_controller.dart';
import 'package:mobile_app/controller/common_controller.dart';
import 'package:mobile_app/controller/file_controller.dart';
import 'package:mobile_app/controller/inbox_controller.dart';
import 'package:mobile_app/controller/properties_tax_controller.dart';
import 'package:mobile_app/controller/timeline_controller.dart';
import 'package:mobile_app/model/citizen/files/file_store.dart';
import 'package:mobile_app/model/citizen/properties_tax/my_properties.dart';
import 'package:mobile_app/model/employee/emp_pt_model/emp_pt_model.dart' as pt;
import 'package:mobile_app/model/employee/status_map/status_map.dart';
import 'package:mobile_app/utils/constants/i18_key_constants.dart';
import 'package:mobile_app/utils/enums/app_enums.dart';
import 'package:mobile_app/utils/enums/emp_enums.dart';
import 'package:mobile_app/utils/enums/modules.dart';
import 'package:mobile_app/utils/extension/extension.dart';
import 'package:mobile_app/utils/localization/localize_utils.dart';
import 'package:mobile_app/utils/platforms/platforms.dart';
import 'package:mobile_app/utils/utils.dart';
import 'package:mobile_app/widgets/big_text.dart';
import 'package:mobile_app/widgets/build_card.dart';
import 'package:mobile_app/widgets/build_expansion.dart';
import 'package:mobile_app/widgets/colum_header_text.dart';
import 'package:mobile_app/widgets/file_dialogue/file_dilaogue.dart';
import 'package:mobile_app/widgets/header_widgets.dart';
import 'package:mobile_app/widgets/medium_text.dart';
import 'package:mobile_app/widgets/mutation_widget/mutation_details_widget.dart';
import 'package:mobile_app/widgets/mutation_widget/mutation_price_widget.dart';
import 'package:mobile_app/widgets/mutation_widget/registration_details_widget.dart';
import 'package:mobile_app/widgets/owner_card/owner_card_widget.dart';
import 'package:mobile_app/widgets/small_text.dart';
import 'package:mobile_app/screens/employee/emp_pt/emp_pt_details/gis_map_screen.dart';
import 'package:mobile_app/widgets/timeline_widget.dart/timeline_wdget.dart';

class EmpPtDetailsScreen extends StatefulWidget {
  const EmpPtDetailsScreen({super.key});

  @override
  State<EmpPtDetailsScreen> createState() => _EmpPtDetailsScreenState();
}

class _EmpPtDetailsScreenState extends State<EmpPtDetailsScreen> {
  // Controller for handling file fetch and type detection
  final _fileController = Get.find<FileController>();

  // Controller for auth token and user session
  final _authController = Get.find<AuthController>();

  // Controller for fetching workflow and timeline history
  final _timelineController = Get.find<TimelineController>();

  // Controller for fetching property tax data
  final _ptController = Get.find<PropertiesTaxController>();

  // Controller for handling inbox actions and action dialogue
  final _inboxController = Get.find<InboxController>();

  // Index of the selected item passed via route arguments
  int index = 0;

  // Flags to avoid redundant API calls
  bool _isTimelineFetch = false;
  bool _isFileStoreFetch = false;

  // The inbox item containing business object details
  pt.Item? _item;

  // Status map holding workflow state and business service info
  late StatusMap statusMap;

  // Observable loading state to show/hide loaders
  var isLoading = false.obs;

  // Completer used to lazily fetch file store when documents section expands
  Completer<FileStore?> fileStoreFuture = Completer<FileStore?>();

  @override
  void initState() {
    // Extract route arguments passed from the inbox/list screen
    index = Get.arguments?['index'] as int? ?? 0;
    _item = Get.arguments?['item'] as pt.Item?;
    statusMap = Get.arguments?['statusMap'] as StatusMap? ?? StatusMap();
    super.initState();
    _init();
  }

  /// Initializes the screen by fetching property details and workflow in sequence.
  _init() async {
    isLoading.value = true;
    await _getProperties();
    await _getWorkflow();
    isLoading.value = false;
  }

  /// Fetches property details for the current item using propertyId and tenantId.
  Future<void> _getProperties() async {
    try {
      await _ptController.getMyPropertiesEmp(
        token: _authController.token!.accessToken!,
        propertyId: _item!.businessObject!.propertyId!,
        tenantId: _item!.businessObject!.tenantId!,
      );
    } catch (e) {
      dPrint('EMP_PT_Error: $e');
    }
  }

  /// Fetches file store data for property documents and completes the [fileStoreFuture].
  /// Called lazily when the documents expansion tile is opened.
  void getFilesStore() async {
    try {
      fileStoreFuture.complete(
        await _fileController
            .getFiles(
          tenantId: BaseConfig.STATE_TENANT_ID,
          token: _authController.token!.accessToken!,
          fileStoreIds: getFileStoreIds(),
        )
            .then(
          (value) {
            _isFileStoreFetch = true;
            return value;
          },
        ),
      );
    } catch (e) {
      dPrint('EMP_PT_GetFilesStore_Error: $e');
    }
  }

  /// Extracts and returns a comma-separated string of fileStoreIds from property documents.
  /// Returns empty string if no documents are found.
  String getFileStoreIds() {
    if (!isNotNullOrEmpty(
      _ptController.myProperties?.properties?.firstOrNull?.documents,
    )) {
      return '';
    }

    List fileIds = [];
    for (var element
        in _ptController.myProperties!.properties!.first.documents!) {
      fileIds.add(element.fileStoreId);
    }
    return fileIds.join(', ');
  }

  /// Fetches the timeline/process history for the current application.
  /// Sets [_isTimelineFetch] to true after a successful fetch to avoid re-fetching.
  Future<void> _getTimeline() async {
    try {
      await _timelineController
          .getTimelineHistory(
        token: _authController.token!.accessToken!,
        tenantId: _item!.businessObject!.tenantId!,
        businessIds: _item!.businessObject!.acknowledgementNumber!,
      )
          .then((value) {
        _isTimelineFetch = true;
      });
    } catch (e) {
      dPrint('EMP_Timeline Error: $e');
    }
  }

  /// Fetches the workflow business service definition used to build action menu items.
  Future<void> _getWorkflow() async {
    try {
      await _timelineController.getWorkFlow(
        token: _authController.token!.accessToken!,
        tenantId: _item!.businessObject!.tenantId!,
        workFlow: statusMap.businessService!,
      );
    } catch (e) {
      dPrint('Error in getting workflow: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final o = MediaQuery.of(context).orientation;
    return Scaffold(
      appBar: HeaderTop(
        title: getLocalizedString(
          i18.propertyTax.APPLICATION_DETAILS,
          module: Modules.PT,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      bottomNavigationBar: Obx(
        () => isLoading.value
            ? const SizedBox.shrink()
            : (_item!.businessObject!.status! == InboxStatus.IN_WORKFLOW.name
                ? Container(
                    height: 44.h,
                    width: Get.width,
                    margin:
                        EdgeInsets.all(o == Orientation.portrait ? 16.w : 12.w),
                    child: PopupMenuButton(
                      onOpened: () {
                        print("========== TAKE ACTION BUTTON OPENED ==========");
                        dPrint("========== TAKE ACTION BUTTON OPENED ==========");
                      },
                      onCanceled: () {
                        print("========== MENU CANCELED ==========");
                        dPrint("========== MENU CANCELED ==========");
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: BaseConfig.appThemeColor1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            o == Orientation.portrait ? 12.w : 6.w,
                          ),
                        ),
                      ),
                      icon: MediumSelectableTextNotoSans(
                        text: getLocalizedString(i18.common.TAKE_ACTION),
                        size: o == Orientation.portrait ? 14.sp : 8.sp,
                        color: BaseConfig.mainBackgroundColor,
                        fontWeight: FontWeight.w600,
                      ),
                      itemBuilder: (context) {
                        print("========== BUILDING MENU ITEMS ==========");
                        dPrint("========== BUILDING MENU ITEMS ==========");
                        final items = _timelineController
                            .workflowBusinessServices
                            .businessServices!
                            .first
                            .states!
                            .where((s) => s.uuid == statusMap.statusId)
                            .first
                            .actions!
                            .map(
                              (action) {
                                print("Creating menu item: ${action.action}");
                                dPrint("Menu Item: ${action.action}");
                                return PopupMenuItem<String>(
                                  value: action.action,
                                  onTap: () {
                                    print("========== ITEM TAPPED: ${action.action} ==========");
                                  },
                                  child: SmallTextNotoSans(
                                    text: LocalizeUtils.getTakeActionLocal(
                                      action.action,
                                      workflowCode: statusMap.businessService!,
                                      module: Modules.PT,
                                      isCommon: true,
                                    ),
                                    color: BaseConfig.textColor,
                                    fontWeight: FontWeight.w600,
                                    size: o == Orientation.portrait ? 14.sp : 8.sp,
                                  ),
                                );
                              },
                            )
                            .toList();
                        dPrint("Total menu items: ${items.length}");
                        return items;
                      },
                      onSelected: (value) async {
                        print("========== TAKE ACTION CLICKED ==========");
                        print("Selected Action: $value");
                        dPrint("========== TAKE ACTION CLICKED ==========");
                        dPrint("Selected Action: $value");
                        dPrint("Work Flow Id: ${statusMap.businessService!}");
                        dPrint("Status Map ID: ${statusMap.statusId}");
                        dPrint("Tenant ID: ${_item!.businessObject!.tenantId!}");
                        
                        // Visual confirmation
                        snackBar('Action Clicked', 'Processing: $value', Colors.blue);

                        try {
                          // Get the next state of the action
                          dPrint("Fetching next state UUID...");
                          String uuid = _timelineController
                                  .workflowBusinessServices
                                  .businessServices
                                  ?.first
                                  .states
                                  ?.where((s) => s.uuid == statusMap.statusId)
                                  .first
                                  .actions
                                  ?.where((a) => a.action == value)
                                  .first
                                  .nextState ??
                              '';

                          dPrint('Next State UUID: $uuid');

                          if (uuid.isEmpty) {
                            dPrint('ERROR: UUID is empty!');
                            snackBar(
                              'InComplete',
                              'Next State is Empty',
                              Colors.green,
                            );
                            return;
                          }

                          dPrint('Checking action type...');
                          if (value != BaseAction.reject.name &&
                              value != BaseAction.sendBackToCitizen.name) {
                            dPrint('Fetching employees for UUID: $uuid');
                            await _timelineController.getEmployees(
                              token: _authController.token!.accessToken!,
                              tenantId: _item!.businessObject!.tenantId!,
                              uuid: uuid,
                            );
                            dPrint('Employees fetched successfully');
                          } else {
                            dPrint('Skipping employee fetch for action: $value');
                          }

                          if (!context.mounted) {
                            dPrint('ERROR: Context not mounted!');
                            return;
                          }

                          dPrint('Opening action dialogue...');
                          _inboxController.actionDialogue(
                            context,
                            workFlowId: statusMap.businessService!,
                            action: value,
                            module: Modules.PT,
                            sectionType: ModulesEmp.PT_SERVICES,
                            tenantId: _item!.businessObject!.tenantId!,
                            businessService: BusinessService.PT,
                          );
                          dPrint('Action dialogue called successfully');
                        } catch (e, stackTrace) {
                          dPrint('ERROR in onSelected: $e');
                          dPrint('StackTrace: $stackTrace');
                        }
                        dPrint("========== TAKE ACTION END ==========");
                      },
                    ),
                  )
                : const SizedBox.shrink()),
      ),
      body: SizedBox(
        height: Get.height,
        width: Get.width,
        child: Obx(
          () => isLoading.value
              ? showCircularIndicator()
              : SingleChildScrollView(
                  physics: AppPlatforms.platformPhysics(),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => Get.to(() => const GisMapScreen()),
                              icon: const Icon(
                                Icons.map_outlined,
                                color: BaseConfig.redColor1,
                              ),
                              label: MediumSelectableTextNotoSans(
                                text: 'Map',
                                color: BaseConfig.redColor1,
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                if (!_isTimelineFetch) {
                                  await _getTimeline();
                                }
                                TimelineHistoryApp.buildTimelineDialogue(
                                  context,
                                  tenantId: BaseConfig.STATE_TENANT_ID,
                                );
                              },
                              child: MediumSelectableTextNotoSans(
                                text: getLocalizedString(
                                  i18.common.TIMELINE,
                                  module: Modules.PT,
                                ),
                                color: BaseConfig.redColor1,
                              ),
                            ),
                          ],
                        ),
                        _buildDetails(),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  /// Builds the main details card containing all property sections:
  /// address, assessment, floor units, ownership, mutation, and documents.
  Widget _buildDetails() => BuildCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ColumnHeaderText(
              label: getLocalizedString(
                i18.propertyTax.APPLICATION_NUMBER_LABEL,
                module: Modules.PT,
              ),
              text: _ptController.property.acknowledgementNumber ?? 'N/A',
            ).paddingOnly(left: 7),
            const SizedBox(height: 10),
            ColumnHeaderText(
              label: getLocalizedString(
                i18.propertyTax.PROPERTY_UID,
                module: Modules.PT,
              ),
              text: _ptController.property.propertyId ?? 'N/A',
            ).paddingOnly(left: 7),
            const SizedBox(height: 10),
            ColumnHeaderText(
              label: getLocalizedString(
                i18.propertyTax.APPLICATION_CHANNEL_LABEL,
                module: Modules.PT,
              ),
              text: isNotNullOrEmpty(_ptController.property.channel)
                  ? _ptController.property.channel!.capitalize!
                  : 'N/A',
            ).paddingOnly(left: 7),
            const SizedBox(height: 10),
            if (_ptController.property.creationReason ==
                CreationReason.MUTATION.name) ...[
              MutationPriceWidget(
                property: _ptController.property,
                token: _authController.token!.accessToken!,
                service: _item?.businessObject?.businessService ??
                    _item?.processInstance?.businessService ??
                    '',
              ),
            ],
            BigSelectableTextNotoSans(
              text: getLocalizedString(
                i18.tlProperty.ADDRESS_HEADER,
                module: Modules.PT,
              ),
              size: 16.sp,
              fontWeight: FontWeight.w600,
            ).paddingOnly(left: 7),
            const SizedBox(height: 10),
            _buildAddress(
              address: _ptController.property.address,
            ).paddingOnly(left: 7),
            BuildExpansion(
              title: getLocalizedString(
                i18.propertyTax.ASSESSMENT_DETAILS_HEADER,
                module: Modules.PT,
              ),
              tilePadding: EdgeInsets.only(left: 7.w),
              children: [
                _buildPropertyAssessment(
                  _ptController.myProperties!.properties!.first,
                ),
              ],
            ),
            if (_ptController.property.units != null) ...[
              BuildExpansion(
                title: getLocalizedString(
                  i18.propertyTax.GROUND_FLOOR,
                  module: Modules.PT,
                ),
                tilePadding: EdgeInsets.only(left: 7.w),
                children: [
                  ListView.builder(
                    itemCount: _ptController.property.units?.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final unit = _ptController
                          .myProperties?.properties?.first.units?[index];
                      return _buildGroundFloorCard(unit!, index + 1)
                          .paddingOnly(left: 7, right: 7, bottom: 10);
                    },
                  ),
                ],
              ),
            ],
            if (isNotNullOrEmpty(_ptController.property.owners)) ...[
              BuildExpansion(
                title: getLocalizedString(
                  i18.propertyTax.OWNERSHIP_DETAILS_HEADER,
                  module: Modules.PT,
                ),
                tilePadding: EdgeInsets.only(left: 7.w),
                children: [
                  ListView.builder(
                    itemCount: _ptController.property.owners!.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final owner = _ptController.property.owners![index];
                      return OwnerCardWidget(
                        property: _ptController.property,
                        owner: owner,
                        index: index,
                      );
                    },
                  ),
                ],
              ),
            ],
            if (_item?.processInstance?.businessService ==
                BusinessService.PT_MUTATION.name) ...[
              BuildExpansion(
                title: getLocalizedString(
                  i18.propertyTax.PT_MUTATION_DETAILS,
                  module: Modules.PT,
                ),
                tilePadding: EdgeInsets.only(left: 7.w),
                children: [
                  MutationDetailsWidget(property: _ptController.property)
                      .paddingOnly(left: 7),
                ],
              ),
              BuildExpansion(
                title: getLocalizedString(
                  i18.propertyTax.PT_REGISTRATION_DETAILS,
                  module: Modules.PT,
                ),
                tilePadding: EdgeInsets.only(left: 7.w),
                children: [
                  RegistrationDetailsWidget(property: _ptController.property)
                      .paddingOnly(left: 7),
                ],
              ),
            ],
            if (isNotNullOrEmpty(_ptController.property.documents)) ...[
              BuildExpansion(
                title: getLocalizedString(i18.common.DOCUMENTS),
                tilePadding: EdgeInsets.only(left: 7.w),
                onExpansionChanged: (isExpand) {
                  if (isExpand && !_isFileStoreFetch) {
                    getFilesStore();
                  }
                },
                children: [
                  FutureBuilder(
                    future: fileStoreFuture.future,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        var fileData = snapshot.data!;
                        return _buildDocuments(fileData);
                      } else if (snapshot.hasError) {
                        return networkErrorPage(
                          context,
                          () => _fileController.getFiles(
                            tenantId: BaseConfig.STATE_TENANT_ID,
                            token: _authController.token!.accessToken!,
                            fileStoreIds: getFileStoreIds(),
                          ),
                        );
                      } else {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return showCircularIndicator();
                          case ConnectionState.active:
                            return showCircularIndicator();
                          default:
                            return const SizedBox.shrink();
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          ],
        ),
      );

  /// Builds the assessment details section showing usage, property type,
  /// land area, floors, electricity number, and UID.
  Widget _buildPropertyAssessment(Property property) => Column(
        children: [
          ColumnHeaderText(
            label: getLocalizedString(i18.tlProperty.USE, module: Modules.PT),
            text: getLocalizedString(
              '${i18.propertyTax.PROPERTYTAX_BILLING_SLAB}${property.usageCategory}',
            ),
          ),
          const SizedBox(height: 10),
          ColumnHeaderText(
            label: getLocalizedString(
              i18.propertyTax.PROPERTY_TYPE,
              module: Modules.PT,
            ),
            text: isNotNullOrEmpty(property.propertyType)
                ? getLocalizedString(
                    '${i18.propertyTax.PROPERTYTAX_BILLING_SLAB}${property.propertyType!.split('.').first}',
                    module: Modules.PT,
                  )
                : 'N/A',
          ),
          const SizedBox(height: 10),
          ColumnHeaderText(
            label: getLocalizedString(i18.propertyTax.AREA, module: Modules.PT),
            text: '${property.landArea?.toInt()} sq.ft',
          ),
          const SizedBox(height: 10),
          ColumnHeaderText(
            label: getLocalizedString(
              i18.tlProperty.NO_OF_FLOOR,
              module: Modules.PT,
            ),
            text: parseNoOfFloors(property.noOfFloors),
            // property.noOfFloors != null
            //     ? property.noOfFloors.toString()
            //     : 'N/A',
          ),
          const SizedBox(height: 10),
          ColumnHeaderText(
            label: getLocalizedString(
              i18.propertyTax.ASSESMENT1_ELECTRICITY_NUMBER,
              module: Modules.PT,
            ),
            text: property.additionalDetails?.electricity ?? 'N/A',
          ),
          const SizedBox(height: 10),
          ColumnHeaderText(
            label: getLocalizedString(
              i18.propertyTax.ASSESMENT1_ELECTRICITY_UID,
              module: Modules.PT,
            ),
            text: property.additionalDetails?.uid ?? 'N/A',
          ),
          const SizedBox(height: 10),
        ],
      );

  /// Builds the address section showing pincode, city, locality, street, and house number.
  Widget _buildAddress({Address? address}) => Column(
        children: [
          ColumnHeaderText(
            label:
                getLocalizedString(i18.tlProperty.PINCODE, module: Modules.PT),
            text: address?.pincode ?? 'N/A',
          ),
          const SizedBox(height: 10),
          ColumnHeaderText(
            label: getLocalizedString(i18.propertyTax.CITY, module: Modules.PT),
            text: address?.city ?? 'N/A',
          ),
          const SizedBox(height: 10),
          ColumnHeaderText(
            label: getLocalizedString(
              i18.propertyTax.LOCALITY_OR_MOHALLA,
              module: Modules.PT,
            ),
            text: address?.locality?.name ?? 'N/A',
          ),
          const SizedBox(height: 10),
          ColumnHeaderText(
            label: getLocalizedString(
              i18.tlProperty.STREET_NAME,
              // module: Modules.PT,
            ),
            text: address?.street ?? 'N/A',
          ),
          const SizedBox(height: 10),
          ColumnHeaderText(
            label: getLocalizedString(
              i18.propertyTax.EMP_HOUSE_NO,
              // module: Modules.PT,
            ),
            text: address?.buildingName ?? 'N/A',
          ),
          const SizedBox(height: 10),
        ],
      );

  /// Builds a card for a single floor unit showing usage type, occupancy, built-up area, and ARV.
  Widget _buildGroundFloorCard(Unit unit, int index) {
    final unitUsageType =
        (unit.usageCategory != null && unit.usageCategory!.contains('.'))
            ? unit.usageCategory!.split('.')[1]
            : unit.usageCategory;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              children: [
                BigSelectableTextNotoSans(
                  text: getLocalizedString(
                    i18.propertyTax.UNIT,
                    module: Modules.PT,
                  ),
                  size: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color.fromRGBO(80, 90, 95, 1.0),
                ),
                BigSelectableTextNotoSans(
                  text: ' $index',
                  size: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color.fromRGBO(80, 90, 95, 1.0),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ColumnHeaderText(
              label: getLocalizedString(
                i18.propertyTax.UNIT_USAGE_TYPE,
                module: Modules.PT,
              ),
              text: getLocalizedString(
                '${i18.propertyTax.PROPERTYTAX_BILLING_SLAB}$unitUsageType',
              ),
            ),
            const SizedBox(height: 10),
            ColumnHeaderText(
              label: getLocalizedString(
                i18.propertyTax.UNIT_OCCUPANY_TYPE,
                module: Modules.PT,
              ),
              text: getLocalizedString(
                unit.occupancyType,
                module: Modules.PT,
              ),
            ),
            const SizedBox(height: 10),
            ColumnHeaderText(
              label: getLocalizedString(
                i18.propertyTax.UNIT_BUILTUP_AREA,
                module: Modules.PT,
              ),
              text: '${unit.constructionDetail?.builtUpArea} sq.ft',
            ),
            if (unit.arv != null) ...[
              const SizedBox(height: 10),
              ColumnHeaderText(
                label: getLocalizedString(
                  i18.propertyTax.FORM2_TOTAL_ANNUAL_RENT,
                  module: Modules.PT,
                ),
                text: '₹${unit.arv}',
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds the documents grid view. Shows a grid of document icons with type labels.
  /// Tapping a document opens a preview dialogue based on file type (PDF or image).
  Widget _buildDocuments(FileStore fileStore) {
    return fileStore.fileStoreIds!.isEmpty
        ? const DocumentsNotFound(module: Modules.PT)
            .paddingSymmetric(horizontal: 10.0)
        : Padding(
            padding: const EdgeInsets.all(10.0),
            child: GridView.builder(
              itemCount: fileStore.fileStoreIds!.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                mainAxisExtent: 110.0, //110
              ),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final fileUrl =
                    fileStore.fileStoreIds?[index].url?.split(',').firstOrNull;
                final docType = _ptController
                    .myProperties?.properties?.first.documents
                    ?.firstWhereOrNull(
                  (element) =>
                      element.fileStoreId == fileStore.fileStoreIds?[index].id,
                );
                return isNotNullOrEmpty(docType)
                    ? Column(
                        children: [
                          Container(
                            width: Get.width,
                            decoration: BoxDecoration(
                              color: BaseConfig.greyColor2,
                              // border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                _fileController.getFileType(fileUrl!).$1,
                                size: 40,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Tooltip(
                            message: getLocalizedString(
                              docType!.documentType,
                              module: Modules.PT,
                            ),
                            child: SmallTextNotoSans(
                              text: getLocalizedString(
                                docType.documentType,
                                module: Modules.PT,
                              ),
                              color: Colors.grey.shade600,
                              maxLine: 2,
                              textOverflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ).ripple(() {
                        final fileType =
                            _fileController.getFileType(fileUrl).$2;
                        dPrint('FileType: ${fileType.name}');
                        if (fileType.name == FileExtType.pdf.name) {
                          showTypeDialogue(
                            context,
                            url: fileUrl,
                            isPdf: true,
                            title: getLocalizedString(
                              docType.documentType,
                              module: Modules.PT,
                            ),
                          );
                        } else {
                          showTypeDialogue(
                            context,
                            url: fileUrl,
                            title: getLocalizedString(
                              docType.documentType,
                              module: Modules.PT,
                            ),
                          );
                        }
                      })
                    : const SizedBox.shrink();
              },
            ),
          );
  }
}
