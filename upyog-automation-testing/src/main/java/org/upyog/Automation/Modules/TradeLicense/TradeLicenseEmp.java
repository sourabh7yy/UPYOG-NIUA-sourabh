package org.upyog.Automation.Modules.TradeLicense;

import java.util.List;
import org.openqa.selenium.By;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.interactions.Actions;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;
import org.upyog.Automation.Utils.ConfigReader;
import org.upyog.Automation.Utils.DriverFactory;

//@Component
public class TradeLicenseEmp {

    //@PostConstruct
    public void TradeLicenseEmpReg() {
        tlInboxEmp(ConfigReader.get("employee.base.url"),
                   ConfigReader.get("app.login.username"),
                   ConfigReader.get("app.login.password"),
                   ConfigReader.get("tl.application.number"));
    }

    public void tlInboxEmp(String baseUrl, String username, String password, String applicationNumber) {
        System.out.println("Trade License Employee Workflow");

        WebDriver driver = DriverFactory.createChromeDriver();
        WebDriverWait wait = DriverFactory.createWebDriverWait(driver);
        JavascriptExecutor js = (JavascriptExecutor) driver;
        Actions actions = new Actions(driver);

        try {
            // STEP 1: Employee Login
            performEmployeeLogin(driver, wait, js, actions, baseUrl, username, password);
            
            // STEP 2: Navigate to Trade License Inbox
            navigateToInbox(driver, wait, js);
            
            // STEP 3: Search Application
            searchApplication(driver, wait, applicationNumber);
            
            // STEP 4: Process Application Workflow
            processApplicationWorkflow(driver, wait);
            
            // STEP 5: Collect Payment
            collectPayment(driver, wait);
            
            // STEP 6: Download Receipts
            downloadReceipts(driver, wait, js);
            
            System.out.println("Trade License Employee Workflow completed successfully!");
            Thread.sleep(50000);
            
        } catch (Exception e) {
            System.out.println("Exception in Trade License Employee Workflow: " + e.getMessage());
            e.printStackTrace();
        } finally {
            // driver.quit();
        }
    }

    private void performEmployeeLogin(WebDriver driver, WebDriverWait wait, JavascriptExecutor js, Actions actions, String baseUrl, String username, String password) throws InterruptedException {
        driver.get(baseUrl);
        driver.manage().window().maximize();
        System.out.println("Open the Employee Login Portal");

        fillInput(wait, "username", username);
        fillInput(wait, "password", password);
        System.out.println("Filled username and password");

        selectCityDropdown(driver, wait, actions);
        clickButton(wait, js, "//button[contains(@class, 'submit-bar') and .//header[text()='Continue']]");
    }

    private void navigateToInbox(WebDriver driver, WebDriverWait wait, JavascriptExecutor js) throws InterruptedException {
        System.out.println("Navigating to Trade License Inbox");
        Thread.sleep(2000);
        
        WebElement inboxLink = wait.until(ExpectedConditions.elementToBeClickable(
                By.xpath("//a[@href='/digit-ui/employee/tl/inbox' and contains(text(), 'Inbox')]")));
        js.executeScript("arguments[0].scrollIntoView(true);", inboxLink);
        inboxLink.click();
        System.out.println("Clicked Inbox link");
    }

    private void searchApplication(WebDriver driver, WebDriverWait wait, String applicationNumber) throws InterruptedException {
        System.out.println("Searching for application by number");
        
        WebElement applicationInput = wait.until(ExpectedConditions.elementToBeClickable(
                By.cssSelector("input.employee-card-input")));
        applicationInput.clear();
        applicationInput.sendKeys(applicationNumber);
        System.out.println("Entered application number: " + applicationNumber);
        
        WebElement searchButton = wait.until(ExpectedConditions.elementToBeClickable(
                By.cssSelector("button.submit-bar.submit-bar-search")));
        searchButton.click();
        System.out.println("Clicked Search button");
        
        Thread.sleep(2000);
        
        WebElement appLink = wait.until(ExpectedConditions.elementToBeClickable(
                By.linkText(applicationNumber)));
        appLink.click();
        System.out.println("Selected application: " + applicationNumber);
    }

    private void processApplicationWorkflow(WebDriver driver, WebDriverWait wait) throws InterruptedException {
        System.out.println("Processing application workflow");
        
        // Step 1: Verify
        clickTakeActionButton(driver, wait);
        handleTakeActionMenu(driver, wait);
        System.out.println("Verification completed");
        
        // Step 2: Approve
        clickTakeActionButton(driver, wait);
        handleTakeActionMenu(driver, wait);
        System.out.println("Approval completed");
        
        // Step 3: Pay
        clickTakeActionButton(driver, wait);
        handleTakeActionMenu(driver, wait);
        System.out.println("Payment process initiated");
    }

    private void collectPayment(WebDriver driver, WebDriverWait wait) {
        System.out.println("Collecting payment");
        
        WebElement mobileInput = wait.until(ExpectedConditions.visibilityOfElementLocated(By.name("payerMobile")));
        mobileInput.clear();
        mobileInput.sendKeys("9847584944");
        
        WebElement collectPaymentButton = wait.until(ExpectedConditions.elementToBeClickable(
                By.xpath("//button[contains(@class, 'submit-bar') and .//header[normalize-space()='Collect Payment']]")));
        collectPaymentButton.click();
        System.out.println("Payment collected");
    }

    private void downloadReceipts(WebDriver driver, WebDriverWait wait, JavascriptExecutor js) throws InterruptedException {
        System.out.println("Downloading receipts");

        List<WebElement> svgButtons = wait.until(ExpectedConditions.visibilityOfAllElementsLocatedBy(
                By.cssSelector("div.primary-label-btn.d-grid")));

        for (WebElement buttonContainer : svgButtons) {
            WebElement svg = buttonContainer.findElement(By.tagName("svg"));
            js.executeScript("arguments[0].scrollIntoView({block: 'center'});", svg);
            Thread.sleep(300);
            svg.click();
            System.out.println("Downloaded: " + buttonContainer.getText().trim());
            Thread.sleep(1000);
        }
        System.out.println("All receipts downloaded");
    }

    // UTILITY METHODS

    private void fillInput(WebDriverWait wait, String fieldName, String value) {
        WebElement input = wait.until(ExpectedConditions.elementToBeClickable(By.name(fieldName)));
        input.clear();
        input.sendKeys(value);
    }

    private void clickButton(WebDriverWait wait, JavascriptExecutor js, String xpath) throws InterruptedException {
        WebElement button = wait.until(ExpectedConditions.elementToBeClickable(By.xpath(xpath)));
        js.executeScript("arguments[0].scrollIntoView(true);", button);
        Thread.sleep(300);
        button.click();
    }

    private void selectCityDropdown(WebDriver driver, WebDriverWait wait, Actions actions) throws InterruptedException {
        WebElement cityDropdownContainer = driver.findElement(By.cssSelector("div.select"));
        WebElement cityDropdownArrow = cityDropdownContainer.findElement(By.tagName("svg"));
        actions.moveToElement(cityDropdownArrow).click().perform();

        WebElement dropdownOptions = wait.until(ExpectedConditions.visibilityOfElementLocated(By.cssSelector("div.options-card")));
        WebElement firstCityOption = dropdownOptions.findElement(By.cssSelector(".profile-dropdown--item:first-child"));
        actions.moveToElement(firstCityOption).click().perform();
    }

    private void clickTakeActionButton(WebDriver driver, WebDriverWait wait) throws InterruptedException {
        WebElement takeActionButton = wait.until(ExpectedConditions.elementToBeClickable(
                By.xpath("//button[contains(@class, 'submit-bar') and .//header[normalize-space()='TAKE ACTION']]")));
        ((JavascriptExecutor) driver).executeScript("arguments[0].scrollIntoView({block: 'center'});", takeActionButton);
        Thread.sleep(300);
        takeActionButton.click();
        System.out.println("Clicked TAKE ACTION button");
    }

    private void handleTakeActionMenu(WebDriver driver, WebDriverWait wait) throws InterruptedException {
        try {
            WebElement menuWrap = wait.until(ExpectedConditions.visibilityOfElementLocated(By.cssSelector("div.menu-wrap")));
            List<WebElement> actionOptions = menuWrap.findElements(By.tagName("p"));

            for (WebElement option : actionOptions) {
                String text = option.getText().trim().toUpperCase();
                if (text.equals("VERIFY")) {
                    option.click();
                    System.out.println("Clicked VERIFY");
                    handlePopupAndSubmit(driver, wait, "Automated verification comment.", 
                            ConfigReader.get("document.identity.proof"));
                    break;
                } else if (text.equals("APPROVE")) {
                    option.click();
                    System.out.println("Clicked APPROVE");
                    handlePopupAndSubmit(driver, wait, "Automated approval comment.", 
                            ConfigReader.get("document.identity.proof"));
                    break;
                } else if (text.equals("PAY")) {
                    option.click();
                    System.out.println("Clicked PAY");
                    break;
                }
            }
        } catch (Exception e) {
            System.out.println("Take Action Menu not found or no valid option present: " + e.getMessage());
        }
    }

    private void handlePopupAndSubmit(WebDriver driver, WebDriverWait wait, String comment, String filePath) throws InterruptedException {
        WebElement commentField = wait.until(ExpectedConditions.visibilityOfElementLocated(By.name("comments")));
        commentField.clear();
        commentField.sendKeys(comment);

        WebElement fileInput = wait.until(ExpectedConditions.presenceOfElementLocated(By.id("workflow-doc")));
        fileInput.sendKeys(filePath);
        System.out.println("Document uploaded");

        List<WebElement> verifyButtons = driver.findElements(By.xpath("//button[contains(@class, 'selector-button-primary') and .//h2[normalize-space()='Verify']]"));
        List<WebElement> approveButtons = driver.findElements(By.xpath("//button[contains(@class, 'selector-button-primary') and .//h2[normalize-space()='Approve']]"));

        WebElement actionButton = null;
        if (!verifyButtons.isEmpty()) {
            actionButton = verifyButtons.get(0);
            System.out.println("Clicking Verify button");
        } else if (!approveButtons.isEmpty()) {
            actionButton = approveButtons.get(0);
            System.out.println("Clicking Approve button");
        } else {
            throw new RuntimeException("Neither Verify nor Approve button found!");
        }

        ((JavascriptExecutor) driver).executeScript("arguments[0].scrollIntoView({block: 'center'});", actionButton);
        Thread.sleep(300);
        actionButton.click();
    }
}
