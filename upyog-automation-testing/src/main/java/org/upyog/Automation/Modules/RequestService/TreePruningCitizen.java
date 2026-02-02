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

@Component
public class TreePruningCitizen {

    //@PostConstruct
    public void TreePruningCreate() {
        TreePruningCreate(ConfigReader.get("citizen.base.url"),
                "Request Service",
                ConfigReader.get("citizen.mobile.number"),
                ConfigReader.get("test.otp"),
                ConfigReader.get("test.city.name"));
    }

    public void TreePruningCreate(String baseUrl, String moduleName, String mobileNumber, String otp, String cityName) {
        System.out.println("Tree Pruning Application by Citizen");

        WebDriver driver = DriverFactory.createChromeDriver();
        WebDriverWait wait = DriverFactory.createWebDriverWait(driver);
        JavascriptExecutor js = (JavascriptExecutor) driver;
        Actions actions = new Actions(driver);

        try {
            // STEP 1: Citizen Login
            performCitizenLogin(driver, wait, js, actions, baseUrl, mobileNumber, otp, cityName);

            // STEP 2: Navigate to Request Service
            navigateToRequestService(driver, wait, js);

            // STEP 3: Select Tree Pruning Service
            selectTreePruningService(driver, wait, js);

            // STEP 4: Fill Tree Pruning Details
            fillTreePruningDetails(driver, wait, js);

            // STEP 5: Fill Applicant Details
            fillApplicantDetails(driver, wait, js);

            // STEP 6: Fill Address Details
            fillAddressDetails(driver, wait, js);

            // STEP 7: Fill Tree Pruning Request Details
            fillTreePruningRequestDetails(driver, wait, js);

            // STEP 8: Upload Documents
            uploadDocuments(driver, wait, js);

            // STEP 9: Submit Application
            submitApplication(driver, wait, js);

            System.out.println("Tree Pruning Application completed successfully!");
            Thread.sleep(50000); // Keep browser open for observation

        } catch (Exception e) {
            System.out.println("Exception in Tree Pruning: " + e.getMessage());
            e.printStackTrace();
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
    // STEP 3: SELECT TREE PRUNING SERVICE
    // =====================================================================

    private void selectTreePruningService(WebDriver driver, WebDriverWait wait, JavascriptExecutor js)
            throws InterruptedException {

        System.out.println("Selecting Tree Pruning Service");
        Thread.sleep(1000);

        // Select Tree Pruning from dropdown (3rd option)
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

        // Tree Pruning is 3rd option (index 2)
        WebElement treePruningOption = options.get(2);
        js.executeScript("arguments[0].scrollIntoView({block:'center'});", treePruningOption);
        Thread.sleep(500);
        js.executeScript("arguments[0].click();", treePruningOption);
        System.out.println("Tree Pruning selected");
        Thread.sleep(1000);

        clickSaveAndNext(wait, js);
    }

    // =====================================================================
    // STEP 4: FILL TREE PRUNING DETAILS
    // =====================================================================

    private void fillTreePruningDetails(WebDriver driver, WebDriverWait wait, JavascriptExecutor js)
            throws InterruptedException {

        System.out.println("Tree Pruning Info Page - Clicking Next");
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
    // STEP 7: FILL TREE PRUNING REQUEST DETAILS
    // =====================================================================

    private void fillTreePruningRequestDetails(WebDriver driver, WebDriverWait wait, JavascriptExecutor js)
            throws InterruptedException {

        System.out.println("Filling Tree Pruning Request Details");
        Thread.sleep(1000);

        // Select reason dropdown
        try {
            selectDropdownOption(driver, wait, js, 0);
            Thread.sleep(500);
            System.out.println("Selected reason for pruning");
        } catch (Exception e) {
            System.out.println("Reason dropdown not found");
        }

        // Click geo tag icon with timeout
        try {
            WebDriverWait shortWait = new WebDriverWait(driver, java.time.Duration.ofSeconds(5));
            By[] geoTagSelectors = {
                By.xpath("//span[contains(@class,'location')]"),
                By.xpath("//i[contains(@class,'location')]"),
                By.xpath("//button[contains(@class,'location')]"),
                By.cssSelector("[class*='location']"),
                By.cssSelector("[class*='geo']"),
                By.cssSelector("[class*='map']")
            };

            WebElement geoTag = null;
            for (By selector : geoTagSelectors) {
                try {
                    geoTag = shortWait.until(ExpectedConditions.elementToBeClickable(selector));
                    break;
                } catch (Exception ignored) {}
            }

            if (geoTag != null) {
                js.executeScript("arguments[0].scrollIntoView({block:'center'});", geoTag);
                Thread.sleep(300);
                js.executeScript("arguments[0].click();", geoTag);
                Thread.sleep(1000);
                System.out.println("Clicked geo tag icon");
            } else {
                System.out.println("Geo tag icon not found, skipping");
            }
        } catch (Exception e) {
            System.out.println("Geo tag timeout, skipping: " + e.getMessage());
        }

        // Upload document
        try {
            uploadFile(driver, wait, js, 0, ConfigReader.get("document.site.proof"));
            System.out.println("Uploaded supporting document");
        } catch (Exception e) {
            System.out.println("Document upload failed");
        }

        Thread.sleep(1000);
    }

    // =====================================================================
    // STEP 8: UPLOAD DOCUMENTS
    // =====================================================================

    private void uploadDocuments(WebDriver driver, WebDriverWait wait, JavascriptExecutor js)
            throws InterruptedException {

        System.out.println("Uploading Documents");
        Thread.sleep(2000);

        // Upload files
        uploadFile(driver, wait, js, 0, ConfigReader.get("document.site.proof"));
        Thread.sleep(1000);

        clickSaveAndNext(wait, js);
        Thread.sleep(1000);

        System.out.println("Next button not found on documents page, continuing...");
    }

    // =====================================================================
    // STEP 9: SUBMIT APPLICATION
    // =====================================================================

    private void submitApplication(WebDriver driver, WebDriverWait wait, JavascriptExecutor js)
            throws InterruptedException {

        System.out.println("Submitting Tree Pruning Application - Summary Page");
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
        System.out.println("Tree Pruning application: Submit clicked");
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

    private void fillOptionalInput(WebDriver driver, WebDriverWait wait, String fieldName, String value) {
        try {
            WebElement input = wait.until(ExpectedConditions.presenceOfElementLocated(By.name(fieldName)));
            if (input.isDisplayed() && input.isEnabled()) {
                input.clear();
                input.sendKeys(value);
                System.out.println("Filled optional field: " + fieldName);
            }
        } catch (Exception e) {
            System.out.println("Optional field " + fieldName + " not found, skipping");
        }
    }

    private void clickButton(WebDriverWait wait, JavascriptExecutor js, String xpath) throws InterruptedException {
        WebElement button = wait.until(ExpectedConditions.elementToBeClickable(By.xpath(xpath)));
        js.executeScript("arguments[0].scrollIntoView(true);", button);
        Thread.sleep(300);
        button.click();
    }

    private void clickSaveAndNext(WebDriverWait wait, JavascriptExecutor js) throws InterruptedException {
        WebElement btn = wait.until(ExpectedConditions.elementToBeClickable(
                By.xpath("//button[contains(.,'Save & Next')]")));
        js.executeScript("arguments[0].scrollIntoView({block:'center'});", btn);
        js.executeScript("arguments[0].click();", btn);
        Thread.sleep(1000);
    }

    private void clickNextButton(WebDriver driver, WebDriverWait wait, JavascriptExecutor js)
            throws InterruptedException {

        WebElement nextButton = wait.until(ExpectedConditions.elementToBeClickable(
                By.xpath("//button[contains(@class,'submit-bar') and .//header[text()='Next']]")));
        js.executeScript("arguments[0].scrollIntoView({block: 'center'});", nextButton);
        Thread.sleep(200);
        nextButton.click();
        System.out.println("Clicked Next");
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

    private void uploadFile(WebDriver driver, WebDriverWait wait, JavascriptExecutor js,
                            int index, String filePath) throws InterruptedException {

        List<WebElement> fileInputs = wait.until(
                ExpectedConditions.presenceOfAllElementsLocatedBy(
                        By.cssSelector("input[type='file'].input-mirror-selector-button")));

        if (index >= fileInputs.size()) {
            System.out.println("File input index " + index + " not found for path: " + filePath);
            return;
        }

        WebElement fileInput = fileInputs.get(index);
        js.executeScript("arguments[0].scrollIntoView({block:'center'});", fileInput);
        js.executeScript("arguments[0].style.opacity='1'; arguments[0].style.display='block';", fileInput);
        Thread.sleep(300);

        fileInput.sendKeys(filePath);
        System.out.println("Uploaded file at index " + index + ": " + filePath);
        Thread.sleep(500);
    }
}
