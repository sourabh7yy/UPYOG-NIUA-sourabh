package org.upyog.Automation.Service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.upyog.Automation.Common.CommonEmployeeTest;

@Service
public class EmployeeTestService {

    private static final Logger logger = LoggerFactory.getLogger(EmployeeTestService.class);

    public String runEmployeeTest(String baseUrl, String moduleName, String username, String password, String applicationNumber) {
        logger.info("Starting {} employee test", moduleName);

        new Thread(() -> {
            try {
                CommonEmployeeTest empTest = new CommonEmployeeTest();
                empTest.runEmployeeTest(baseUrl, moduleName, username, password, applicationNumber);
            } catch (Exception e) {
                logger.error("Error in employee test: {}", e.getMessage());
            }
        }).start();

        return moduleName + " employee test started successfully. Check browser for automation.";
    }
}
