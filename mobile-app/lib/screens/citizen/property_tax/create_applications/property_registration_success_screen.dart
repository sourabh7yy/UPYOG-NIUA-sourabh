import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mobile_app/config/base_config.dart';
import 'package:mobile_app/widgets/header_widgets.dart';

class PropertyRegistrationSuccessScreen extends StatelessWidget {
  final String applicationNo;
  final String mainTitle;
  final String appIdName;
  final String message;

  const PropertyRegistrationSuccessScreen({
    super.key,
    required this.applicationNo,
    required this.mainTitle,
    required this.appIdName,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HeaderTop(
        titleWidget: Text(mainTitle),
        onPressed: () => Get.back(),
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: BaseConfig.statusGreenColor,
              ),
              child: Icon(
                Icons.check,
                size: 40.sp,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Success!',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w600,
                color: BaseConfig.statusGreenColor,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              message,
              style: TextStyle(
                fontSize: 16.sp,
                color: BaseConfig.textColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                border: Border.all(color: BaseConfig.borderColor),
                borderRadius: BorderRadius.circular(8.r),
                color: BaseConfig.greyColor1.withOpacity(0.1),
              ),
              child: Column(
                children: [
                  Text(
                    appIdName,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: BaseConfig.textColor2,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    applicationNo,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: BaseConfig.appThemeColor1,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: () {
                  Get.offAllNamed('/PROPERTY_APPLICATIONS');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: BaseConfig.appThemeColor1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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