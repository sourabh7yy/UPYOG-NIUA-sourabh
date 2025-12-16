package org.upyog.Automation.Modules.TradeLicense;

import org.openqa.selenium.By;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.interactions.Actions;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;
import org.springframework.stereotype.Component;
import org.upyog.Automation.Utils.ConfigReader;
import org.upyog.Automation.Utils.DriverFactory;

import javax.annotation.PostConstruct;
import java.util.List;

/**
 * Automated test class for UPYOG Trade License Employee Inbox Workflow
 * This class handles the complete employee-side trade license processing including:
 * - Employee login and city selection
 * - Navigation to Trade License Inbox
 * - Application search and selection
 * - Complete workflow: Verify and Forward -> Approve -> Pay
 * - Payment collection
 */
//@Component
public class InboxEmpTl {

    /**
     * Main test method for trade license employee workflow
     * Runs automatically when Spring context is initialized
     */
    //@PostConstruct
    public void InboxEmpTl() {
        System.out.println("Trade License Employee Inbox Workflow");
        
        // Initialize WebDriver using DriverFactory
        WebDriver driver = DriverFactory.createChromeDriver();
        WebDriverWait wait = DriverFactory.createWebDriverWait(driver);
        JavascriptExecutor js = (JavascriptExecutor) driver;
        Actions actions = new Actions(driver);

        try {
            // STEP 1: Employee Login
            performEmployeeLogin(driver, wait, js, actions);
            
            // STEP 2: Navigate to Trade License Inbox
            navigateToInbox(driver, wait, js);
            
            // STEP 3: Search and Select Application
            searchAndSelectApplication(driver, wait);
            
            // STEP 4: Execute Complete Workflow
            runWorkflow(driver, wait);
            
            // STEP 5: Collect Payment
            collectPayment(driver, wait);
            
            System.out.println("Trade License Employee Workflow completed successfully!");
            Thread.sleep(50000); // Keep browser open for observation
            
        } catch (Exception e) {
            System.out.println("Exception in Trade License Employee Workflow: " + e.getMessage());
            e.printStackTrace();
        } finally {
            // Uncomment to close browser after test
            // driver.quit();
        }
    }

    /**
     * Handles employee login process
     */
    private void performEmployeeLogin(WebDriver driver, WebDriverWait wait, JavascriptExecutor js, Actions actions) throws InterruptedException {
        driver.get(ConfigReader.get("employee.base.url"));
        driver.manage().window().maximize();
        System.out.println("Open the Employee Login Portal");

        // Enter credentials from configuration
        fillInput(wait, "username", ConfigReader.get("tl.login.username"));
        fillInput(wait, "password", ConfigReader.get("tl.login.password"));
        System.out.println("Filled username and password");

        // Select city dropdown
        selectCityDropdown(driver, wait, actions);
        
        // Click Continue button
        WebElement continueButton = wait.until(ExpectedConditions.elementToBeClickable(
                By.xpath("//button[contains(@class, 'submit-bar') and .//header[text()='Continue']]")));
        js.executeScript("arguments[0].scrollIntoView(true);", continueButton);
        continueButton.click();
    }

    /**
     * Navigates to Trade License Inbox
     */
    private void navigateToInbox(WebDriver driver, WebDriverWait wait, JavascriptExecutor js) throws InterruptedException {
        System.out.println("Navigating to Trade License Inbox");
        
        Thread.sleep(300);
        
        WebElement tlInbox = wait.until(ExpectedConditions.visibilityOfElementLocated(
                By.xpath("//a[contains(@href, '/upyog-ui/employee/tl/inbox') and contains(normalize-space(.), 'Inbox')]")));
        js.executeScript("arguments[0].scrollIntoView({block: 'center'});", tlInbox);
        Thread.sleep(300);
        js.executeScript("arguments[0].click();", tlInbox);
        System.out.println("Clicked Trade License Inbox");
    }

    /**
     * Searches for and selects application
     */
    private void searchAndSelectApplication(WebDriver driver, WebDriverWait wait) throws InterruptedException {
        System.out.println("Searching and selecting application");
        
        Thread.sleep(1000);
        
        // Enter application number
        String appNumber = ConfigReader.get("tl.application.number");
        WebElement appNumberInput = wait.until(ExpectedConditions.visibilityOfElementLocated(
                By.className("employee-card-input")));
        appNumberInput.clear();
        appNumberInput.sendKeys(appNumber);

        // Click search button
        WebElement searchButton = wait.until(ExpectedConditions.elementToBeClickable(
                By.className("submit-bar-search")));
        searchButton.click();

        // Click on application link
        WebElement appLink = wait.until(ExpectedConditions.visibilityOfElementLocated(
                By.linkText(appNumber)));
        appLink.click();
        System.out.println("Selected application: " + appNumber);
    }

    /**
     * Executes the complete workflow: Verify and Forward -> Approve -> Pay
     */
    private void runWorkflow(WebDriver driver, WebDriverWait wait) throws InterruptedException {
        System.out.println("Executing complete workflow");
        
        verifyAndForwardStep(driver, wait); // 1st Verify and Forward
        verifyAndForwardStep(driver, wait); // 2nd Verify and Forward
        approveStep(driver, wait);          // Approve
        payStep(driver, wait);              // Pay
        
        System.out.println("Full workflow completed successfully!");
    }

    /**
     * Handles payment collection
     */
    private void collectPayment(WebDriver driver, WebDriverWait wait) {
        System.out.println("Collecting payment");
        
        // Enter mobile number for payment
        WebElement mobileInput = wait.until(ExpectedConditions.visibilityOfElementLocated(By.name("payerMobile")));
        mobileInput.clear();
        mobileInput.sendKeys("9847584944");

        // Click Collect Payment button
        WebElement collectPaymentButton = wait.until(ExpectedConditions.elementToBeClickable(
                By.xpath("//button[contains(@class, 'submit-bar') and .//header[normalize-space()='Collect Payment']]")));
        collectPaymentButton.click();
        System.out.println("Payment collected");
    }

    // WORKFLOW STEP METHODS

    /**
     * Executes Verify and Forward step
     */
    private void verifyAndForwardStep(WebDriver driver, WebDriverWait wait) throws InterruptedException {
        clickTakeActionButton(driver, wait);
        selectMenuOption(driver, wait, "VERIFY AND FORWARD");
        fillComments(driver, wait, "verify");
        clickActionButton(driver, wait, "Verify and Forward");
    }

    /**
     * Executes Approve step
     */
    private void approveStep(WebDriver driver, WebDriverWait wait) throws InterruptedException {
        clickTakeActionButton(driver, wait);
        selectMenuOption(driver, wait, "APPROVE");
        fillComments(driver, wait, "approve");
        clickActionButton(driver, wait, "Approve");
    }

    /**
     * Executes Pay step
     */
    private void payStep(WebDriver driver, WebDriverWait wait) throws InterruptedException {
        clickTakeActionButton(driver, wait);
        selectMenuOption(driver, wait, "PAY");
        System.out.println("Clicked PAY in workflow");
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
     * Selects city dropdown during login
     */
    private void selectCityDropdown(WebDriver driver, WebDriverWait wait, Actions actions) throws InterruptedException {
        WebElement cityDropdownContainer = driver.findElement(By.cssSelector("div.select"));
        WebElement cityDropdownArrow = cityDropdownContainer.findElement(By.tagName("svg"));
        actions.moveToElement(cityDropdownArrow).click().perform();

        WebElement dropdownOptions = wait.until(ExpectedConditions.visibilityOfElementLocated(
                By.cssSelector("div.options-card")));
        WebElement firstCityOption = dropdownOptions.findElement(By.cssSelector(".profile-dropdown--item:first-child"));
        actions.moveToElement(firstCityOption).click().perform();
    }

    /**
     * Clicks the TAKE ACTION button
     */
    private void clickTakeActionButton(WebDriver driver, WebDriverWait wait) throws InterruptedException {
        WebElement takeActionButton = wait.until(ExpectedConditions.elementToBeClickable(
                By.xpath("//button[contains(@class, 'submit-bar') and .//header[normalize-space()='TAKE ACTION']]")));
        ((JavascriptExecutor) driver).executeScript("arguments[0].scrollIntoView({block: 'center'});", takeActionButton);
        Thread.sleep(300);
        takeActionButton.click();
        System.out.println("Clicked TAKE ACTION button");
    }

    /**
     * Selects menu option from take action menu
     */
    private void selectMenuOption(WebDriver driver, WebDriverWait wait, String optionText) throws InterruptedException {
        WebElement menuWrap = wait.until(ExpectedConditions.visibilityOfElementLocated(By.cssSelector("div.menu-wrap")));
        List<WebElement> actionOptions = menuWrap.findElements(By.tagName("p"));
        
        boolean found = false;
        for (WebElement option : actionOptions) {
            if (option.getText().trim().equalsIgnoreCase(optionText)) {
                ((JavascriptExecutor) driver).executeScript("arguments[0].scrollIntoView({block: 'center'});", option);
                Thread.sleep(200);
                option.click();
                System.out.println("Clicked menu option: " + optionText);
                found = true;
                break;
            }
        }
        if (!found) throw new RuntimeException("Menu option '" + optionText + "' not found!");
    }

    /**
     * Fills comments in the workflow popup
     */
    private void fillComments(WebDriver driver, WebDriverWait wait, String comment) {
        WebElement textarea = wait.until(ExpectedConditions.visibilityOfElementLocated(By.name("comments")));
        textarea.clear();
        textarea.sendKeys(comment);
        System.out.println("Filled comments: " + comment);
    }

    /**
     * Clicks action button in workflow popup
     */
    private void clickActionButton(WebDriver driver, WebDriverWait wait, String btnText) throws InterruptedException {
        WebElement btn = wait.until(ExpectedConditions.elementToBeClickable(
                By.xpath("//button[contains(@class,'selector-button-primary')][.//h2[normalize-space()='" + btnText + "']]")));
        ((JavascriptExecutor) driver).executeScript("arguments[0].scrollIntoView({block: 'center'});", btn);
        Thread.sleep(200);
        
        try {
            btn.click();
        } catch (Exception e) {
            ((JavascriptExecutor) driver).executeScript("arguments[0].click();", btn);
        }
        System.out.println("Clicked action button: " + btnText);
    }
}