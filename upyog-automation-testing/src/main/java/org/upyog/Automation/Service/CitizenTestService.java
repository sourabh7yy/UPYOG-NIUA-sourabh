package org.upyog.Automation.Service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.upyog.Automation.Common.CommonCitizenTest;

@Service
public class CitizenTestService {

    private static final Logger logger = LoggerFactory.getLogger(CitizenTestService.class);

    public String runCitizenSideTest(String baseUrl, String moduleName, String mobileNumber, String otp, String cityName) {
        logger.info("Starting {} citizen test", moduleName);

        new Thread(() -> {
            try {
                CommonCitizenTest test = new CommonCitizenTest();
                test.runCitizenTest(baseUrl, moduleName, mobileNumber, otp, cityName);
            } catch (Exception e) {
                logger.error("Error in citizen test: {}", e.getMessage());
            }
        }).start();

        return moduleName + " test started successfully. Check browser for automation.";
    }
}
