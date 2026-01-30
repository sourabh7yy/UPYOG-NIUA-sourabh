package org.upyog.Automation.Controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;
import org.upyog.Automation.Service.CitizenTestService;
import org.upyog.Automation.Service.EmployeeTestService;

@RestController
@RequestMapping("/api/test")
@CrossOrigin(origins = "*")
public class TestController {

    @Autowired
    private CitizenTestService citizenTestService;

    @Autowired
    private EmployeeTestService employeeTestService;

    @PostMapping("/citizen")
    public ResponseEntity<String> runCitizenTest(@RequestBody CitizenTestRequest request) {
        String result = citizenTestService.runCitizenSideTest(
                request.getBaseUrl(),
                request.getModuleName(),
                request.getMobileNumber(),
                request.getOtp(),
                request.getCityName()
        );
        return ResponseEntity.ok(result);
    }

    @PostMapping("/employee")
    public ResponseEntity<String> runEmployeeTest(@RequestBody EmployeeTestRequest request) {
        String result = employeeTestService.runEmployeeTest(
                request.getBaseUrl(),
                request.getModuleName(),
                request.getUsername(),
                request.getPassword(),
                request.getApplicationNumber()
        );
        return ResponseEntity.ok(result);
    }

    // Request DTOs
    public static class CitizenTestRequest {
        private String baseUrl;
        private String moduleName;
        private String mobileNumber;
        private String otp;
        private String cityName;

        // Getters and Setters
        public String getBaseUrl() { return baseUrl; }
        public void setBaseUrl(String baseUrl) { this.baseUrl = baseUrl; }
        public String getModuleName() { return moduleName; }
        public void setModuleName(String moduleName) { this.moduleName = moduleName; }
        public String getMobileNumber() { return mobileNumber; }
        public void setMobileNumber(String mobileNumber) { this.mobileNumber = mobileNumber; }
        public String getOtp() { return otp; }
        public void setOtp(String otp) { this.otp = otp; }
        public String getCityName() { return cityName; }
        public void setCityName(String cityName) { this.cityName = cityName; }
    }

    public static class EmployeeTestRequest {
        private String baseUrl;
        private String username;
        private String password;
        private String applicationNumber;
        private String moduleName;

        // Getters and Setters
        public String getBaseUrl() { return baseUrl; }
        public void setBaseUrl(String baseUrl) { this.baseUrl = baseUrl; }
        public String getUsername() { return username; }
        public void setUsername(String username) { this.username = username; }
        public String getPassword() { return password; }
        public void setPassword(String password) { this.password = password; }
        public String getApplicationNumber() { return applicationNumber; }
        public void setApplicationNumber(String applicationNumber) { this.applicationNumber = applicationNumber; }
        public String getModuleName() { return moduleName; }
        public void setModuleName(String moduleName) { this.moduleName = moduleName; }
    }
}
