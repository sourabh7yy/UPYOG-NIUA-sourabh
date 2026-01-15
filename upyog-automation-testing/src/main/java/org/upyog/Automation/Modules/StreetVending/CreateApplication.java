package org.upyog.Automation.Modules.StreetVending;

import java.util.List;
import org.openqa.selenium.By;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.interactions.Actions;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.upyog.Automation.Utils.ConfigReader;
import org.upyog.Automation.Utils.DriverFactory;


//@Component
public class CreateApplication {

    private static final Logger logger = LoggerFactory.getLogger(CreateApplication.class);

    //@PostConstruct
    public void svCreateApplication() {

        logger.info("Street Vending Registration by Citizen");

        // Initialize WebDriver using DriverFactory
        WebDriver driver = DriverFactory.createChromeDriver();
        WebDriverWait wait = DriverFactory.createWebDriverWait(driver);
        JavascriptExecutor js = (JavascriptExecutor) driver;
        Actions actions = new Actions(driver);

        try {
            // STEP 1: Citizen Login
            performCitizenLogin(driver, wait, js, actions);

            // STEP 2: Navigate to Street Vending Application
            navigateToStreetVending(driver, wait, js);

            // STEP 3: Fill Vendor Personal Details
            fillVendorPersonalDetails(driver, wait, js);

            // STEP 4: Fill Vendor Business Details
            fillVendorBusinessDetails(driver, wait, js);

            // STEP 5: Fill Vendor Address Details
            fillVendorAddressDetails(driver, wait, js);

            // STEP 6: Fill Vendor Bank Details
            fillVendorBankDetails(driver, wait, js);

            // STEP 7: Upload Documents
            uploadDocuments(driver, wait, js);

            //Step 8: Special Category / Schemes
            selectOwnerCategory(driver, wait, js);

            //Step 9: Accept Declaration
            acceptDeclaration(driver, wait, js);

            //Step 10: Download Acknowledgement
            downloadAcknowledgement(driver, wait, js);

            logger.info("Street Vending Registration completed successfully!");
            Thread.sleep(50000); // Keep browser open for observation

        } catch (Exception e) {
            logger.error("Exception in Street Vending Registration: " + e.getMessage(), e);
        } finally {
            // Uncomment to close browser after test
            // driver.quit();
        }
    }

    /**
     * Handles citizen login process
     */
    private void performCitizenLogin(WebDriver driver, WebDriverWait wait, JavascriptExecutor js, Actions actions) throws InterruptedException {
        driver.get(ConfigReader.get("citizen.base.url"));
        logger.info("Open the Citizen Login Portal");

        // Enter mobile number
        fillInput(wait, "mobileNumber", ConfigReader.get("citizen.mobile.number"));

        // Accept terms and conditions checkbox
        WebElement checkbox = wait.until(ExpectedConditions.presenceOfElementLocated(
                By.cssSelector("input[type='checkbox'].form-field")));
        if (!checkbox.isSelected()) {
            js.executeScript("arguments[0].click();", checkbox);
            Thread.sleep(1000);
        }

        // Click Next
        clickButton(wait, js, "//button[@type='submit']//header[text()='Next']/..");

        // Fill OTP
        wait.until(ExpectedConditions.visibilityOfElementLocated(By.cssSelector("div.input-otp-wrap")));
        List<WebElement> otpInputs = driver.findElements(By.cssSelector("input.input-otp"));
        String otp = ConfigReader.get("test.otp");
        for (int i = 0; i < otp.length() && i < otpInputs.size(); i++) {
            otpInputs.get(i).sendKeys(String.valueOf(otp.charAt(i)));
        }

        // Submit OTP
        clickButton(wait, js, "//button[@type='submit']//header[text()='Next']/..");

        // Select city
        selectCity(driver, wait, js, ConfigReader.get("test.city.name"));

        // Continue to home page
        WebElement continueBtn = wait.until(ExpectedConditions.elementToBeClickable(
                By.xpath("//button[contains(@class, 'submit-bar') and contains(., 'Continue')]")));
        js.executeScript("arguments[0].scrollIntoView(true);", continueBtn);
        actions.moveToElement(continueBtn).click().perform();
    }

    /**
     * Navigates to Street Vending application
     */
    private void navigateToStreetVending(WebDriver driver, WebDriverWait wait, JavascriptExecutor js) throws InterruptedException {
        logger.info("Navigating to Street Vending Application");
        
        // Click Street Vending sidebar link
        js.executeScript("arguments[0].click();", wait.until(ExpectedConditions.presenceOfElementLocated(
                By.xpath("//a[@href='/sv-ui/citizen/sv-home']"))));

        // Click Apply for Street Vending License
        js.executeScript("arguments[0].click();", wait.until(ExpectedConditions.elementToBeClickable(
                By.xpath("//a[@href='/sv-ui/citizen/sv/apply']"))));

        // Click Next on document requirements page
        WebElement nextBtn = wait.until(ExpectedConditions.elementToBeClickable(
                By.xpath("//span/button[contains(@class,'submit-bar')]//header[normalize-space()='Next']/..")));
        js.executeScript("arguments[0].scrollIntoView({block: 'center'});", nextBtn);
        Thread.sleep(500);
        js.executeScript("arguments[0].click();", nextBtn);
    }

    /**
     * Fills vendor personal details
     */
    private void fillVendorPersonalDetails(WebDriver driver, WebDriverWait wait, JavascriptExecutor js) throws InterruptedException {
        logger.info("Filling Vendor Personal Details");
        
        // Select first dropdown option
        selectDropdownOption(driver, wait, 0);
        
        // Fill Date of Birth
        WebElement dateInput = wait.until(ExpectedConditions.visibilityOfElementLocated(
                By.cssSelector("input.employee-card-input[type='date']")));
        dateInput.clear();
        dateInput.sendKeys("20-05-1990");
        
        // Select Gender
        selectRadioButtonByLabel(driver, "Male");
        
        // Fill Father's Name
        fillInput(wait, "fatherName", "Father Name");
        
        // Click Save & Next
        clickButtonByHeader(driver, wait, "Save & Next");
    }

    /**
     * Fills vendor business details
     */
    private void fillVendorBusinessDetails(WebDriver driver, WebDriverWait wait, JavascriptExecutor js) throws InterruptedException {
        logger.info("Filling Vendor Business Details");
        
        // Select Vending Type
        selectDropdownOption(driver, wait, 0);
        
        // Select Locality
        selectDropdownOptionByText(driver, wait, 1, "Patiala");
        
        // Select Vending Zones
        selectDropdownOption(driver, wait, 2);
        
        // Select checkbox
        WebElement checkbox = wait.until(ExpectedConditions.presenceOfElementLocated(
                By.cssSelector("input.SVCheckbox[type='checkbox']")));
        if (!checkbox.isSelected()) {
            ((JavascriptExecutor) driver).executeScript("arguments[0].click();", checkbox);
        }
        
        // Fill Local Authority Name
        fillInput(wait, "nameOfAuthority", "Local Authority");
        
        // Select Payment Cycle
        selectDropdownOption(driver, wait, 3);
        
        // Fill Vending License
        fillInput(wait, "vendingLiscence", "VL123456");
        
        // Click Save & Next
        clickButtonByHeader(driver, wait, "Save & Next");
    }

    /**
     * Fills vendor address details
     */
    private void fillVendorAddressDetails(WebDriver driver, WebDriverWait wait, JavascriptExecutor js) throws InterruptedException {
        logger.info("Filling Vendor Address Details");
        
        // Fill House No
        fillInput(wait, "houseNo", "123");
        
        // Fill Address Line 1
        fillInput(wait, "addressline1", "Main Street");
        
        // Fill Address Line 2
        fillInput(wait, "addressline2", "Near Park");
        
        // Fill Landmark
        fillInput(wait, "landmark", "City Mall");
        
        // Select City
        selectDropdownOption(driver, wait, 0);
        
        // Select Locality
        selectDropdownOption(driver, wait, 1);
        
        // Fill Pincode
        fillInput(wait, "pincode", "147001");
        
        // Click Save & Next (First)
        clickButtonByHeader(driver, wait, "Save & Next");
        
        // Select Same as Permanent Address checkbox
        WebElement sameAddressCheckbox = wait.until(ExpectedConditions.presenceOfElementLocated(
                By.cssSelector("input[type='checkbox'][value='Same as Permanent Address']")));
        if (!sameAddressCheckbox.isSelected()) {
            ((JavascriptExecutor) driver).executeScript("arguments[0].click();", sameAddressCheckbox);
        }

        // Click Save & Next (Second)
        clickButtonByHeader(driver, wait, "Save & Next");
    }

    /**
     * Fills vendor bank details
     */
    private void fillVendorBankDetails(WebDriver driver, WebDriverWait wait, JavascriptExecutor js) throws InterruptedException {
        logger.info("Filling Vendor Bank Details");
        
        // Fill Account Number
        fillInput(wait, "accountNumber", "123456789012");
        
        // Fill Confirm Account Number
        fillInput(wait, "confirmAccountNumber", "123456789012");
        
        // Fill IFSC Code
        fillInput(wait, "ifscCode", "SBIN0003453");
        
        // Fill Account Holder Name
        fillInput(wait, "accountHolderName", "John Doe");
        
        // Click Save & Next
        clickButtonByHeader(driver, wait, "Save & Next");
    }

    /**
     * Uploads required documents
     */
    private void uploadDocuments(WebDriver driver, WebDriverWait wait, JavascriptExecutor js) throws InterruptedException {
        logger.info("Uploading Documents");
        
        String[] filePaths = {
            "/Users/kaveri/Downloads/1765952287364QizTgOLXYI.png",
            "/Users/kaveri/Downloads/Dashboard service.pdf",
            "/Users/kaveri/Downloads/Dashboard service.pdf",
            "/Users/kaveri/Downloads/Dashboard service.pdf"
        };
        
        // Get all dropdowns in document section
        List<WebElement> allDropdowns = driver.findElements(By.cssSelector("div.select svg.cp"));
        int documentDropdownStartIndex = allDropdowns.size() - 4;
        
        // Select dropdown and upload file for each document
        for (int i = 0; i < 4; i++) {
            // Select dropdown first option
            selectDropdownOption(driver, wait, documentDropdownStartIndex + i);
            Thread.sleep(500);
            
            // Upload file
            List<WebElement> fileInputs = driver.findElements(
                    By.cssSelector("input.input-mirror-selector-button[type='file']"));
            if (i < fileInputs.size()) {
                WebElement fileInput = fileInputs.get(i);
                js.executeScript("arguments[0].scrollIntoView({block: 'center'});", fileInput);
                Thread.sleep(300);
                fileInput.sendKeys(filePaths[i]);
                Thread.sleep(1000);
            }
        }
        
        // Click Save & Next
        clickButtonByHeader(driver, wait, "Save & Next");
    }

    /**
     * Selects owner category
     */
    private void selectOwnerCategory(WebDriver driver, WebDriverWait wait, JavascriptExecutor js) throws InterruptedException {
        logger.info("Selecting Owner Category");
        
        Thread.sleep(1000);
        
        // Find the Owner Category dropdown by its label
        WebElement ownerCategorySection = wait.until(ExpectedConditions.presenceOfElementLocated(
                By.xpath("//h2[contains(text(),'Owner Category')]/following-sibling::div//div[@class='select undefined']")));
        
        // Scroll into view
        js.executeScript("arguments[0].scrollIntoView({block: 'center'});", ownerCategorySection);
        Thread.sleep(500);
        
        // Click the dropdown container
        try {
            ownerCategorySection.click();
        } catch (Exception e) {
            Actions actions = new Actions(driver);
            actions.moveToElement(ownerCategorySection).click().perform();
        }
        
        Thread.sleep(1000);
        
        // Select "None of the above" option
        WebElement optionsContainer = wait.until(ExpectedConditions.visibilityOfElementLocated(
                By.cssSelector("div.options-card")));
        List<WebElement> options = optionsContainer.findElements(By.cssSelector("div.profile-dropdown--item"));
        
        for (WebElement option : options) {
            if (option.getText().trim().equalsIgnoreCase("None of the above")) {
                try {
                    option.click();
                } catch (Exception e) {
                    Actions actions = new Actions(driver);
                    actions.moveToElement(option).click().perform();
                }
                logger.info("Selected: None of the above");
                break;
            }
        }
        
        Thread.sleep(500);
        clickButtonByHeader(driver, wait, "Save & Next");
    }

    /**
     * Accepts declaration checkbox
     */
    private void acceptDeclaration(WebDriver driver, WebDriverWait wait, JavascriptExecutor js) throws InterruptedException {
        logger.info("Accepting Declaration");
        
        Thread.sleep(1000);
        
        // Find declaration checkbox by value
        WebElement declarationCheckbox = wait.until(ExpectedConditions.presenceOfElementLocated(
                By.cssSelector("input[type='checkbox'][value*='I hereby declare']")));
        
        // Scroll into view
        js.executeScript("arguments[0].scrollIntoView({block: 'center'});", declarationCheckbox);
        Thread.sleep(500);
        
        // Check if not already selected
        if (!declarationCheckbox.isSelected()) {
            js.executeScript("arguments[0].click();", declarationCheckbox);
            logger.info("Declaration checkbox selected");
        }
        
        Thread.sleep(500);
        
        // Click Submit Application button
        clickButtonByHeader(driver, wait, "Submit Application");
        logger.info("Application submitted successfully");
    }

    /**
     * Downloads acknowledgement
     */
    private void downloadAcknowledgement(WebDriver driver, WebDriverWait wait, JavascriptExecutor js) throws InterruptedException {
        logger.info("Downloading Acknowledgement");
        
        Thread.sleep(2000);
        
        // Click Download Acknowledgement button
        clickButtonByHeader(driver, wait, "Download Acknowledgement");
        logger.info("Acknowledgement downloaded successfully");
        
        Thread.sleep(2000);
    }

    /**
     * Selects dropdown option by text
     */
    private void selectDropdownOptionByText(WebDriver driver, WebDriverWait wait, int dropdownIndex, String optionText) throws InterruptedException {
        List<WebElement> dropdownSvgs = wait.until(ExpectedConditions.visibilityOfAllElementsLocatedBy(
                By.cssSelector("div.select svg.cp")));
        
        WebElement dropdownSvg = dropdownSvgs.get(dropdownIndex);
        dropdownSvg.click();
        Thread.sleep(500);
        
        WebElement optionsContainer = wait.until(ExpectedConditions.visibilityOfElementLocated(
                By.cssSelector("div.options-card")));
        List<WebElement> options = optionsContainer.findElements(By.cssSelector("div.profile-dropdown--item"));
        
        for (WebElement option : options) {
            if (option.getText().trim().equalsIgnoreCase(optionText)) {
                ((JavascriptExecutor) driver).executeScript("arguments[0].click();", option);
                break;
            }
        }
    }

    /**
     * Selects dropdown option by index
     */
    private void selectDropdownOption(WebDriver driver, WebDriverWait wait, int dropdownIndex) throws InterruptedException {
        List<WebElement> dropdownSvgs = wait.until(ExpectedConditions.visibilityOfAllElementsLocatedBy(
                By.cssSelector("div.select svg.cp")));
        
        WebElement dropdownSvg = dropdownSvgs.get(dropdownIndex);
        ((JavascriptExecutor) driver).executeScript("arguments[0].scrollIntoView({block: 'center'});", dropdownSvg);
        Thread.sleep(300);
        
        try {
            dropdownSvg.click();
        } catch (Exception e) {
            ((JavascriptExecutor) driver).executeScript("arguments[0].click();", dropdownSvg);
        }
        Thread.sleep(500);
        
        WebElement optionsContainer = wait.until(ExpectedConditions.visibilityOfElementLocated(
                By.cssSelector("div.options-card")));
        List<WebElement> options = optionsContainer.findElements(By.cssSelector("div.profile-dropdown--item"));
        
        if (!options.isEmpty()) {
            try {
                options.get(0).click();
            } catch (Exception e) {
                ((JavascriptExecutor) driver).executeScript("arguments[0].click();", options.get(0));
            }
        }
    }

    /**
     * Selects radio button by label text
     */
    private void selectRadioButtonByLabel(WebDriver driver, String labelText) {
        try {
            WebElement radio = driver.findElement(By.xpath("//label[text()='" + labelText + "']/preceding-sibling::span/input"));
            if (!radio.isSelected()) {
                ((JavascriptExecutor) driver).executeScript("arguments[0].click();", radio);
            }
        } catch (Exception e) {
            WebElement radio = driver.findElement(By.xpath("//input[@type='radio'][@value='" + labelText + "']"));
            if (!radio.isSelected()) {
                ((JavascriptExecutor) driver).executeScript("arguments[0].click();", radio);
            }
        }
    }

    /**
     * Clicks button by header text
     */
    private void clickButtonByHeader(WebDriver driver, WebDriverWait wait, String headerText) throws InterruptedException {
        WebElement button = wait.until(ExpectedConditions.elementToBeClickable(
                By.xpath("//button[contains(@class, 'submit-bar') and .//header[contains(text(),'" + headerText + "')]]")));
        ((JavascriptExecutor) driver).executeScript("arguments[0].scrollIntoView({block: 'center'});", button);
        ((JavascriptExecutor) driver).executeScript("arguments[0].click();", button);
        Thread.sleep(500);
    }

    // UTILITY METHODS

    /**
     * Utility method to fill input fields
     */
    private void fillInput(WebDriverWait wait, String fieldName, String value) {
        WebElement input = wait.until(ExpectedConditions.elementToBeClickable(By.name(fieldName)));
        input.clear();
        input.sendKeys(value);
    }

    /**
     * Utility method to click buttons with XPath
     */
    private void clickButton(WebDriverWait wait, JavascriptExecutor js, String xpath) throws InterruptedException {
        WebElement button = wait.until(ExpectedConditions.elementToBeClickable(By.xpath(xpath)));
        js.executeScript("arguments[0].scrollIntoView(true);", button);
        Thread.sleep(300);
        button.click();
    }

    /**
     * Selects city during login
     */
    private void selectCity(WebDriver driver, WebDriverWait wait, JavascriptExecutor js, String cityName) throws InterruptedException {
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
        throw new RuntimeException("Failed to select " + cityName);
    }

}