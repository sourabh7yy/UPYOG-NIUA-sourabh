package org.upyog.Automation.Modules.RequestService;

import java.util.List;
import org.openqa.selenium.By;
import org.openqa.selenium.ElementClickInterceptedException;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.interactions.Actions;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;
import org.springframework.stereotype.Component;
import org.upyog.Automation.Utils.ConfigReader;
import org.upyog.Automation.Utils.DriverFactory;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;


@Component
public class MobileToiletCitizen {

    //@PostConstruct
    public void MobileToiletCreate() {
        MobileToiletCreate(ConfigReader.get("citizen.base.url"),
                "Request Service",
                ConfigReader.get("citizen.mobile.number"),
                ConfigReader.get("test.otp"),
                ConfigReader.get("test.city.name"));

    }

    public void MobileToiletCreate(String baseUrl, String moduleName, String mobileNumber, String otp, String cityName) {
        System.out.println("Create Application by Citizen");

        WebDriver driver = DriverFactory.createChromeDriver();
        WebDriverWait wait = DriverFactory.createWebDriverWait(driver);
        JavascriptExecutor js = (JavascriptExecutor) driver;
        Actions actions = new Actions(driver);

        try {
            // STEP 1: Citizen Login
            performCitizenLogin(driver, wait, js, actions, baseUrl, mobileNumber, otp, cityName);

            // STEP 2: Navigate to Request Service
            navigateToRequestService(driver, wait, js);

            // STEP 3: Select Mobile Toilet Service
            selectMobileToiletService(driver, wait, js);

            // STEP 4: Fill Mobile Toilet Details
            fillMobileToiletDetails(driver, wait, js);

            // STEP 5: Fill Applicant Details
            fillApplicantDetails(driver, wait, js);

            // STEP 6: Fill Address Details
            fillAddressDetails(driver, wait, js);

            // STEP 7: Mobile Toilet Request Details
            fillMobileToiletRequestDetails(driver, wait, js);

            // STEP 8: Submit Application
            submitApplication(driver, wait, js);


        } catch (Exception e) {
            System.out.println("Exception in Mobile Toilet: " + e.getMessage());
        } finally {
            // driver.quit();
        }
    }

    // =====================================================================
    // STEP 1: CITIZEN LOGIN
    // =====================================================================

    private void performCitizenLogin(WebDriver driver, WebDriverWait wait, JavascriptExecutor js, Actions actions, String baseUrl, String mobileNumber, String otp, String cityName)
            throws InterruptedException {

        driver.get(baseUrl);
        System.out.println("Open the Citizen Login Portal");

        // Mobile number
        fillInput(wait, "mobileNumber", mobileNumber);

        // Accept terms checkbox
        WebElement checkbox = wait.until(ExpectedConditions.presenceOfElementLocated(
                By.cssSelector("input[type='checkbox'].form-field")));
        if (!checkbox.isSelected()) {
            js.executeScript("arguments[0].click();", checkbox);
            Thread.sleep(1000);
        }

        // Next
        clickButton(wait, js, "//button[@type='submit']//header[text()='Next']/..");

        // OTP
        wait.until(ExpectedConditions.visibilityOfElementLocated(By.cssSelector("div.input-otp-wrap")));
        List<WebElement> otpInputs = driver.findElements(By.cssSelector("input.input-otp"));
        for (int i = 0; i < otp.length() && i < otpInputs.size(); i++) {
            otpInputs.get(i).sendKeys(String.valueOf(otp.charAt(i)));
        }

        // Submit OTP
        clickButton(wait, js, "//button[@type='submit']//header[text()='Next']/..");

        // Select city
        selectCity(driver, wait, js, cityName);

        // Continue
        WebElement continueBtn = wait.until(ExpectedConditions.elementToBeClickable(
                By.xpath("//button[contains(@class, 'submit-bar') and contains(., 'Continue')]")));
        js.executeScript("arguments[0].scrollIntoView(true);", continueBtn);
        actions.moveToElement(continueBtn).click().perform();
        Thread.sleep(3000);
    }

    // =====================================================================
    // STEP 2: NAVIGATE TO REQUEST SERVICE
    // =====================================================================

    private void navigateToRequestService(WebDriver driver, WebDriverWait wait, JavascriptExecutor js)
            throws InterruptedException {

        System.out.println("Navigating to Request Service");

        // Sidebar Request Service link
        js.executeScript("arguments[0].click();", wait.until(ExpectedConditions.presenceOfElementLocated(
                By.xpath("//a[@href='/upyog-ui/citizen/wt-home']"))));
        Thread.sleep(3000);
        // "Request Service" card
        js.executeScript("arguments[0].click();", wait.until(ExpectedConditions.elementToBeClickable(
                By.xpath("//div[contains(@class,'CitizenHomeCard')]//a[text()='Select Request Service']"))));

        Thread.sleep(3000);
    }

    // =====================================================================
    // STEP 3: SELECT MOBILE TOILET SERVICE
    // =====================================================================

    private void selectMobileToiletService(WebDriver driver, WebDriverWait wait, JavascriptExecutor js)
            throws InterruptedException {

        System.out.println("Selecting Mobile Toilet Service");
        Thread.sleep(1000);

        // Select Mobile Toilet from dropdown (1st option)
        List<WebElement> dropdownSvgs = wait.until(
                ExpectedConditions.visibilityOfAllElementsLocatedBy(
                        By.cssSelector("div.select svg.cp")));

        WebElement serviceTypeDropdown = dropdownSvgs.get(0);
        js.executeScript("arguments[0].scrollIntoView({block:'center'});", serviceTypeDropdown);
        Thread.sleep(500);

        try {
            serviceTypeDropdown.click();
        } catch (Exception e) {
            js.executeScript(
                    "var ev = document.createEvent('MouseEvents');" +
                            "ev.initEvent('click', true, true);" +
                            "arguments[0].dispatchEvent(ev);",
                    serviceTypeDropdown);
        }

        WebElement optionsContainer = wait.until(
                ExpectedConditions.visibilityOfElementLocated(
                        By.cssSelector("div.options-card")));

        List<WebElement> options = optionsContainer.findElements(
                By.cssSelector("div.profile-dropdown--item"));

        // Mobile Toilet is 2nd option (index 0)
        WebElement MobileToiletOption = options.get(1);
        js.executeScript("arguments[0].scrollIntoView({block:'center'});", MobileToiletOption);
        Thread.sleep(500);
        js.executeScript("arguments[0].click();", MobileToiletOption);
        System.out.println("Mobile Toilet Service selected");
        Thread.sleep(1000);

        clickSaveAndNext(wait, js);
    }
    // =====================================================================
    // STEP 4: FILL MOBILE TOILET DETAILS
    // =====================================================================

    private void fillMobileToiletDetails(WebDriver driver, WebDriverWait wait, JavascriptExecutor js)
            throws InterruptedException {

        System.out.println("Mobile Toilet Info Page - Clicking Next");
        Thread.sleep(2000);

        // Try multiple Next button selectors for info page
        By[] nextSelectors = {
                By.xpath("//button[contains(.,'Next')]"),
                By.xpath("//button[contains(@class,'submit-bar') and .//header[text()='Next']]"),
                By.xpath("//button[@type='button' and contains(.,'Next')]"),
                By.xpath("//*[contains(text(),'Next')]/parent::button")
        };

        for (By selector : nextSelectors) {
            try {
                WebElement nextBtn = wait.until(ExpectedConditions.elementToBeClickable(selector));
                js.executeScript("arguments[0].scrollIntoView({block:'center'});", nextBtn);
                Thread.sleep(500);
                js.executeScript("arguments[0].click();", nextBtn);
                System.out.println("Clicked Next on info page");
                return;
            } catch (Exception e) {
                System.out.println("Next selector failed: " + selector);
            }
        }

        throw new RuntimeException("Next button not found on info page");
    }

    // =====================================================================
    // STEP 5: FILL APPLICANT DETAILS
    // =====================================================================

    private void fillApplicantDetails(WebDriver driver, WebDriverWait wait, JavascriptExecutor js)
            throws InterruptedException {

        System.out.println("Filling Applicant Details");

        fillInput(wait, "applicantName", "Arpit Rao");
        fillInput(wait, "emailId", "arpit@gmail.com");

        // Fill mobile number if not pre-filled
        try {
            fillInput(wait, "mobileNumber", "9999999999");
        } catch (Exception e) {
            System.out.println("Mobile number field not found or pre-filled");
        }

        Thread.sleep(2000);

        // Try multiple Next button selectors
        By[] nextSelectors = {
                By.xpath("//button[contains(.,'Next')]"),
                By.xpath("//button[contains(@class,'submit-bar') and .//header[text()='Next']]"),
                By.xpath("//button[@type='button' and contains(.,'Next')]"),
                By.xpath("//*[contains(text(),'Next')]/parent::button")
        };

        for (By selector : nextSelectors) {
            try {
                WebElement nextBtn = wait.until(ExpectedConditions.elementToBeClickable(selector));
                js.executeScript("arguments[0].scrollIntoView({block:'center'});", nextBtn);
                Thread.sleep(500);
                js.executeScript("arguments[0].click();", nextBtn);
                System.out.println("Clicked Next on applicant details page");
                return;
            } catch (Exception e) {
                System.out.println("Next selector failed: " + selector);
            }
        }

        throw new RuntimeException("Next button not found on applicant details page");
    }

    // =====================================================================
    // STEP 6: FILL ADDRESS DETAILS
    // =====================================================================

    private void fillAddressDetails(WebDriver driver, WebDriverWait wait, JavascriptExecutor js)
            throws InterruptedException {

        System.out.println("Filling Address Details");

        // Select address type (Permanent/Current) - try index 0 first
        try {
            selectDropdownOption(driver, wait, js, 0);
            Thread.sleep(1000);
            System.out.println("Selected address type");
        } catch (Exception e) {
            System.out.println("Address type dropdown not found");
        }

        // Fill address fields
        fillInput(wait, "houseNo", "A-12");
        fillInput(wait, "streetName", "Test Street");

        // Try different field names for address line 1 with short timeout
        try {
            fillInputFast(driver, wait, "addressline1", "Address Line 1");
        } catch (Exception e) {
            try {
                fillInputFast(driver, wait, "addressLine1", "Address Line 1");
            } catch (Exception e2) {
                try {
                    fillInputFast(driver, wait, "address1", "Address Line 1");
                } catch (Exception e3) {
                    System.out.println("Address line 1 field not found");
                }
            }
        }

        // Try different field names for address line 2 with short timeout
        try {
            fillInputFast(driver, wait, "addressline2", "Address Line 2");
        } catch (Exception e) {
            try {
                fillInputFast(driver, wait, "addressLine2", "Address Line 2");
            } catch (Exception e2) {
                try {
                    fillInputFast(driver, wait, "address2", "Address Line 2");
                } catch (Exception e3) {
                    System.out.println("Address line 2 field not found");
                }
            }
        }
        fillInput(wait, "landmark", "Near Test Landmark");

        // Select city dropdown
        try {
            selectDropdownOption(driver, wait, js, 1);
            Thread.sleep(1000);
            System.out.println("Selected city");
        } catch (Exception e) {
            System.out.println("City dropdown not found");
        }

        // Select locality dropdown after city selection loads more dropdowns
        Thread.sleep(1000);
        try {
            selectDropdownOption(driver, wait, js, 2);
            Thread.sleep(1000);
            System.out.println("Selected locality");
        } catch (Exception e) {
            System.out.println("Locality dropdown not found");
        }

        fillInput(wait, "pincode", "110011");

        Thread.sleep(1000);

        // Try multiple Next button selectors
        By[] nextSelectors = {
                By.xpath("//button[contains(.,'Next')]"),
                By.xpath("//button[contains(@class,'submit-bar') and .//header[text()='Next']]"),
                By.xpath("//button[@type='button' and contains(.,'Next')]"),
                By.xpath("//*[contains(text(),'Next')]/parent::button")
        };

        for (By selector : nextSelectors) {
            try {
                WebElement nextBtn = wait.until(ExpectedConditions.elementToBeClickable(selector));
                js.executeScript("arguments[0].scrollIntoView({block:'center'});", nextBtn);
                Thread.sleep(500);
                js.executeScript("arguments[0].click();", nextBtn);
                System.out.println("Clicked Next on address details page");
                return;
            } catch (Exception e) {
                System.out.println("Next selector failed: " + selector);
            }
        }

        throw new RuntimeException("Next button not found on address details page");
    }

    // =====================================================================
    // STEP 7: FILL MOBILE TOILET REQUEST DETAILS
    // =====================================================================

    private void fillMobileToiletRequestDetails(WebDriver driver, WebDriverWait wait, JavascriptExecutor js)
            throws InterruptedException {

        System.out.println("Filling Mobile Toilet Request Details");
        Thread.sleep(1000);

        // Number of Mobile Toilets
        try {
            selectDropdownOption(driver, wait, js, 0);
            Thread.sleep(1000);
            System.out.println("Selected Mobile Toilet Quantity");
        } catch (Exception e) {
            System.out.println("Mobile Toilet Quantity dropdown failed: " + e.getMessage());
        }

        // Select Dates - From Date- To Date (Dynamic dates)
        List<WebElement> dateInputs = wait.until(ExpectedConditions.visibilityOfAllElementsLocatedBy(
                By.cssSelector("input.employee-card-input[type='date']")));

        if (dateInputs.size() >= 2) {
            WebElement fromDate = dateInputs.get(0);
            WebElement toDate = dateInputs.get(1);

            // Get current date and add days for future dates
            LocalDate today = LocalDate.now();
            LocalDate futureFromDate = today.plusDays(7);  // 7 days from today
            LocalDate futureToDate = today.plusDays(10);   // 10 days from today

            // Format dates as dd-MM-yyyy
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd-MM-yyyy");

            fromDate.clear();
            fromDate.sendKeys(futureFromDate.format(formatter));

            toDate.clear();
            toDate.sendKeys(futureToDate.format(formatter));

            System.out.println("From Date: " + futureFromDate.format(formatter));
            System.out.println("To Date: " + futureToDate.format(formatter));
        } else {
            System.out.println("Date inputs not found or less than 2");
        }

        // Special Request
        try {
            WebElement specialRequest = wait.until(ExpectedConditions.elementToBeClickable(
                    By.tagName("textarea")));
            js.executeScript("arguments[0].scrollIntoView({block:'center'});", specialRequest);
            Thread.sleep(500);
            specialRequest.clear();
            specialRequest.sendKeys("Water tanker required for household use");
            System.out.println("Filled description");
        } catch (Exception e) {
            System.out.println("Description textarea failed: " + e.getMessage());
        }

        // Fill From Time separately
        try {
            WebElement fromTimeInput = wait.until(ExpectedConditions.elementToBeClickable(
                    By.xpath("(//input[@type='time'])[1]"))); // First time input
            fillTimeInput(fromTimeInput, "10:30AM", js);
            System.out.println("Filled From Time");
        } catch (Exception e) {
            System.out.println("From Time input failed: " + e.getMessage());
        }

// Fill To Time separately
        try {
            WebElement toTimeInput = wait.until(ExpectedConditions.elementToBeClickable(
                    By.xpath("(//input[@type='time'])[2]"))); // Second time input
            fillTimeInput(toTimeInput, "11:30PM", js); // 11:30 PM in 24-hour format
            System.out.println("Filled To Time");
        } catch (Exception e) {
            System.out.println("To Time input failed: " + e.getMessage());
        }

        // After filling both time inputs
        Thread.sleep(1000);

// Check if all required fields are filled
        js.executeScript("document.querySelectorAll('input[required]').forEach(el => console.log(el.name + ': ' + el.value));");

// Wait for form validation
        Thread.sleep(2000);

        By[] nextSelectors = {
                By.xpath("//button[contains(.,'Next')]"),
                By.xpath("//button[contains(@class,'submit-bar') and .//header[text()='Next']]"),
                By.xpath("//button[@type='button' and contains(.,'Next')]"),
                By.xpath("//*[contains(text(),'Next')]/parent::button")
        };

        for (By selector : nextSelectors) {
            try {
                WebElement nextBtn = wait.until(ExpectedConditions.elementToBeClickable(selector));
                js.executeScript("arguments[0].scrollIntoView({block:'center'});", nextBtn);
                Thread.sleep(500);
                js.executeScript("arguments[0].click();", nextBtn);
                System.out.println("Clicked Next on address details page");
                return;
            } catch (Exception e) {
                System.out.println("Next selector failed: " + selector);
            }
        }

        throw new RuntimeException("Next button not found on address details page");

    }
    // =====================================================================
    // STEP 8: SUBMIT APPLICATION
    // =====================================================================

    private void submitApplication(WebDriver driver, WebDriverWait wait, JavascriptExecutor js)
            throws InterruptedException {

        System.out.println("Submitting Mobile Toilet Application - Summary Page");
        Thread.sleep(3000);

        List<WebElement> checkboxes = driver.findElements(By.cssSelector("input[type='checkbox']"));
        if (!checkboxes.isEmpty()) {
            WebElement lastCheckbox = checkboxes.get(checkboxes.size() - 1);
            try {
                if (!lastCheckbox.isSelected()) {
                    js.executeScript("arguments[0].scrollIntoView(true);", lastCheckbox);
                    Thread.sleep(300);
                    js.executeScript("arguments[0].click();", lastCheckbox);
                    System.out.println("Checked declaration checkbox");
                }
            } catch (Exception ex) {
                System.out.println("Could not click declaration checkbox: " + ex.getMessage());
            }
        }

        WebElement submitButton = wait.until(ExpectedConditions.presenceOfElementLocated(
                By.xpath("//button[@class='submit-bar ' and @type='button'][.//header[text()='Submit']]")));
        js.executeScript("window.scrollTo(0, document.body.scrollHeight);");
        Thread.sleep(300);
        js.executeScript("arguments[0].scrollIntoView({block: 'center'});", submitButton);
        Thread.sleep(200);
        submitButton.click();
        System.out.println("Mobile Toilet application: Submit clicked");
    }

    // =====================================================================
    // UTILITY METHODS
    // =====================================================================

    private void fillInput(WebDriverWait wait, String fieldName, String value) {
        WebElement input = wait.until(ExpectedConditions.elementToBeClickable(By.name(fieldName)));
        input.clear();
        input.sendKeys(value);
    }

    private void fillInputFast(WebDriver driver, WebDriverWait wait, String fieldName, String value) {
        WebDriverWait fastWait = new WebDriverWait(driver, java.time.Duration.ofSeconds(3));
        WebElement input = fastWait.until(ExpectedConditions.elementToBeClickable(By.name(fieldName)));
        input.clear();
        input.sendKeys(value);
    }

    private void clickButton(WebDriverWait wait, JavascriptExecutor js, String xpath) throws InterruptedException {
        WebElement button = wait.until(ExpectedConditions.elementToBeClickable(By.xpath(xpath)));
        js.executeScript("arguments[0].scrollIntoView(true);", button);
        Thread.sleep(300);
        button.click();
    }

    private void selectCity(WebDriver driver, WebDriverWait wait, JavascriptExecutor js, String cityName)
            throws InterruptedException {

        wait.until(ExpectedConditions.visibilityOfElementLocated(
                By.cssSelector("div.radio-wrap.reverse-radio-selection-wrapper")));

        List<WebElement> cityOptions = driver.findElements(
                By.cssSelector("div.radio-wrap.reverse-radio-selection-wrapper div"));

        for (WebElement option : cityOptions) {
            WebElement label = option.findElement(By.tagName("label"));
            if (label.getText().trim().equals(cityName)) {
                WebElement radioInput = option.findElement(By.cssSelector("input[type='radio']"));
                if (!radioInput.isSelected()) {
                    js.executeScript("arguments[0].click();", radioInput);
                    Thread.sleep(1000);
                }
                return;
            }
        }
        throw new RuntimeException("Failed to select city: " + cityName);
    }

    private void clickSaveAndNext(WebDriverWait wait, JavascriptExecutor js) throws InterruptedException {
        WebElement btn = wait.until(ExpectedConditions.elementToBeClickable(
                By.xpath("//button[contains(.,'Save & Next')]")));
        js.executeScript("arguments[0].scrollIntoView({block:'center'});", btn);
        js.executeScript("arguments[0].click();", btn);
        Thread.sleep(1000);
    }

    private void selectDropdownOption(WebDriver driver, WebDriverWait wait, JavascriptExecutor js, int dropdownIndex)
            throws InterruptedException {

        List<WebElement> dropdownSvgs = wait.until(
                ExpectedConditions.visibilityOfAllElementsLocatedBy(
                        By.cssSelector("div.select svg.cp")));

        if (dropdownIndex >= dropdownSvgs.size()) {
            System.out.println("Dropdown index " + dropdownIndex + " not found. Total: " + dropdownSvgs.size());
            return;
        }

        WebElement svg = dropdownSvgs.get(dropdownIndex);
        js.executeScript("arguments[0].scrollIntoView({block:'center'});", svg);
        Thread.sleep(200);

        try {
            svg.click();
        } catch (ElementClickInterceptedException e) {
            js.executeScript(
                    "var ev = document.createEvent('MouseEvents');" +
                            "ev.initEvent('click', true, true);" +
                            "arguments[0].dispatchEvent(ev);",
                    svg);
        }

        WebElement optionsContainer = wait.until(
                ExpectedConditions.visibilityOfElementLocated(
                        By.cssSelector("div.options-card")));

        List<WebElement> options = optionsContainer.findElements(
                By.cssSelector("div.profile-dropdown--item"));

        if (!options.isEmpty()) {
            WebElement firstOption = options.get(0);
            js.executeScript("arguments[0].scrollIntoView({block:'center'});", firstOption);
            Thread.sleep(150);
            js.executeScript("arguments[0].click();", firstOption);
        }
    }

    private void selectRadioByLabel(WebDriver driver, String labelText) {

        WebElement radio = driver.findElement(
                By.xpath("//label[normalize-space()='" + labelText + "']/preceding-sibling::input")
        );

        if (!radio.isSelected()) {
            ((JavascriptExecutor) driver).executeScript("arguments[0].click();", radio);
        }
    }

    private void fillTimeInput(WebElement timeElement, String time, JavascriptExecutor js) throws InterruptedException {
        js.executeScript("arguments[0].scrollIntoView({block:'center'});", timeElement);
        timeElement.click();
        timeElement.clear();
        timeElement.sendKeys(time); // Use "10:30" not "10:30AM"
        js.executeScript("arguments[0].dispatchEvent(new Event('change', {bubbles: true}));", timeElement);
        Thread.sleep(500);
    }
}