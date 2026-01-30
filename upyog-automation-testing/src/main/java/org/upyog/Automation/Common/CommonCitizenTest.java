package org.upyog.Automation.Common;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.upyog.Automation.Modules.Adv.AdvBookingCreate;
import org.upyog.Automation.Modules.Pet.PetCreateApplication;
import org.upyog.Automation.Modules.StreetVending.CreateApplication;
import org.upyog.Automation.Modules.TradeLicense.TradeLicenseCreate;

/**
 * Common entry point for all citizen module tests
 * Routes to appropriate module based on moduleName
 */
public class CommonCitizenTest {

    private static final Logger logger = LoggerFactory.getLogger(CommonCitizenTest.class);

    public void runCitizenTest(String baseUrl, String moduleName, String mobileNumber, String otp, String cityName) {
        logger.info("Starting {} citizen test", moduleName);

        try {
            if ("STREET_VENDING".equalsIgnoreCase(moduleName)) {
                CreateApplication svApp = new CreateApplication();
                svApp.svCreateApplication(baseUrl, moduleName, mobileNumber, otp, cityName);

            } else if ("TRADE_LICENSE".equalsIgnoreCase(moduleName)) {
                TradeLicenseCreate tlApp = new TradeLicenseCreate();
                tlApp.TradeLicenceCitizenReg(baseUrl, moduleName, mobileNumber, otp, cityName);

            } else if ("PET_REGISTRATION".equalsIgnoreCase(moduleName)) {
                PetCreateApplication petApp = new PetCreateApplication();
                petApp.PetApptest(baseUrl, moduleName, mobileNumber, otp, cityName);

            } else if ("ADVERTISEMENT".equalsIgnoreCase(moduleName)) {
                AdvBookingCreate advApp = new AdvBookingCreate();
                advApp.AdvBookingReg(baseUrl, moduleName, mobileNumber, otp, cityName);

            } else {
                logger.error("Unknown module: {}", moduleName);
                throw new RuntimeException("Unknown module: " + moduleName);
            }

            logger.info("{} test completed", moduleName);

        } catch (Exception e) {
            logger.error("Error in {} test: {}", moduleName, e.getMessage());
            throw new RuntimeException(e);
        }
    }
}
