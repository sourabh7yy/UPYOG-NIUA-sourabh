package org.upyog.Automation.Modules.StreetVending;

import javax.annotation.PostConstruct;
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


@Component
public class SvEmp {

    @PostConstruct
    public void InboxEmpSv() {

        System.out.println("SV Employee Inbox Workflow");

        // Initialize WebDriver using DriverFactory
        WebDriver driver = DriverFactory.createChromeDriver();
        WebDriverWait wait = DriverFactory.createWebDriverWait(driver);
        JavascriptExecutor js = (JavascriptExecutor) driver;
        Actions actions = new Actions(driver);

        try {
            // STEP 1: Employee Login
            performEmployeeLogin(driver, wait, js, actions);

            // STEP 2: Navigate to SV Inbox
            navigateToInbox(driver, wait, js);

            // STEP 3: Search and Select Application
            searchAndSelectApplication(driver, wait);

            // STEP 4: Execute Complete Workflow
            runWorkflow(driver, wait);

            System.out.println("SV Employee Workflow completed successfully!");
            Thread.sleep(50000); // Keep browser open for observation

        } catch (Exception e) {
            System.out.println("Exception in SV Employee Workflow: " + e.getMessage());
            e.printStackTrace();
        } finally {
            // Uncomment to close browser after test
            // driver.quit();
        }
    }

    private void performEmployeeLogin(WebDriver driver, WebDriverWait wait, JavascriptExecutor js, Actions actions) throws InterruptedException {
        driver.get(ConfigReader.get("sv.employee.base.url"));
        driver.manage().window().maximize();
        System.out.println("Open the Employee Login Portal");

        // Enter credentials from configuration
        fillInput(wait, "username", ConfigReader.get("sv.login.username"));
        fillInput(wait, "password", ConfigReader.get("SV.login.password"));
        System.out.println("Filled username and password");

        // Select city dropdown
        selectCityDropdown(driver, wait, actions);

        // Click Continue button
        WebElement continueButton = wait.until(ExpectedConditions.elementToBeClickable(
                By.xpath("//button[contains(@class, 'submit-bar') and .//header[text()='Continue']]")));
        js.executeScript("arguments[0].scrollIntoView(true);", continueButton);
        continueButton.click();
    }

    private void fillInput(WebDriverWait wait, String fieldName, String value) {
        WebElement input = wait.until(ExpectedConditions.elementToBeClickable(By.name(fieldName)));
        input.clear();
        input.sendKeys(value);
    }

    private void selectCityDropdown(WebDriver driver, WebDriverWait wait, Actions actions) throws InterruptedException {
        WebElement cityDropdownContainer = driver.findElement(By.cssSelector("div.select"));
        WebElement cityDropdownArrow = cityDropdownContainer.findElement(By.tagName("svg"));
        actions.moveToElement(cityDropdownArrow).click().perform();

        WebElement dropdownOptions = wait.until(ExpectedConditions.visibilityOfElementLocated(
                By.cssSelector("div.options-card")));
        WebElement firstCityOption = dropdownOptions.findElement(By.cssSelector(".profile-dropdown--item:first-child"));
        actions.moveToElement(firstCityOption).click().perform();
    }

    private void navigateToInbox(WebDriver driver, WebDriverWait wait, JavascriptExecutor js) throws InterruptedException {
        System.out.println("Navigating to SV Inbox");

        Thread.sleep(300);

        WebElement svInbox = wait.until(ExpectedConditions.visibilityOfElementLocated(
                By.xpath("//a[contains(@href, '/sv-ui/employee/sv/inbox') and contains(normalize-space(.), 'Inbox')]")));
        js.executeScript("arguments[0].scrollIntoView({block: 'center'});", svInbox);
        Thread.sleep(300);
        js.executeScript("arguments[0].click();", svInbox);
        System.out.println("Clicked SV Inbox");
    }

    private void searchAndSelectApplication(WebDriver driver, WebDriverWait wait) throws InterruptedException {
        System.out.println("Searching and selecting application");

        Thread.sleep(1000);

        // Enter application number
        String appNumber = ConfigReader.get("sv.application.number");
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

    private void runWorkflow(WebDriver driver, WebDriverWait wait) throws InterruptedException {
        System.out.println("========== Executing complete workflow ==========");

        System.out.println("\n========== STARTING 1ST FORWARD ==========");
        FirstForwardStep(driver, wait);
        System.out.println("========== COMPLETED 1ST FORWARD ==========\n");
        
        System.out.println("\n========== STARTING 2ND FORWARD ==========");
        SecondForwardStep(driver, wait);
        System.out.println("========== COMPLETED 2ND FORWARD ==========\n");

        System.out.println("\n========== STARTING APPROVE ==========");
        approveStep(driver, wait);
        System.out.println("========== COMPLETED APPROVE ==========\n");

        System.out.println("\n========== STARTING COLLECT FEES ==========");
        collectFeesStep(driver, wait);
        System.out.println("========== COMPLETED COLLECT FEES ==========\n");

        System.out.println("========== Full workflow completed successfully! ==========");
    }

    private void FirstForwardStep(WebDriver driver, WebDriverWait wait) throws InterruptedException {
        System.out.println("[FORWARD] Step 1: Clicking Take Action button...");
        clickTakeActionButton(driver, wait);
        
        System.out.println("[FORWARD] Step 2: Clicking Forward option...");
        clickForward(driver, wait);
        
        System.out.println("[FORWARD] Step 3: Selecting dropdown option...");
        selectDropdownFirstOption(driver, wait);
        
        System.out.println("[FORWARD] Step 4: Filling comments...");
        fillComments(driver, wait, "Forward");
        
        System.out.println("[FORWARD] Step 5: Clicking Forward button...");
        clickForwardButton(driver, wait);
        
        System.out.println("[FORWARD] All steps completed successfully!");
    }


    private void SecondForwardStep(WebDriver driver, WebDriverWait wait) throws InterruptedException {

        Thread.sleep(2000);
        System.out.println("[FORWARD] Step 1: Clicking Take Action button...");
        clickTakeActionButton2(driver, wait);

        System.out.println("[FORWARD] Step 2: Clicking Forward option...");
        clickForward(driver, wait);

        System.out.println("[FORWARD] Step 3: Selecting dropdown option...");
        selectDropdownFirstOption(driver, wait);

        System.out.println("[FORWARD] Step 4: Filling comments...");
        fillComments(driver, wait, "Forward");

        System.out.println("[FORWARD] Step 5: Clicking Forward button...");
        clickForwardButton(driver, wait);

        System.out.println("[FORWARD] All steps completed successfully!");
    }

    private void clickTakeActionButton(WebDriver driver, WebDriverWait wait) throws InterruptedException {
        WebElement takeActionButton = wait.until(ExpectedConditions.elementToBeClickable(
                By.xpath("//button[contains(@class, 'submit-bar') and .//header[normalize-space()='TAKE ACTION']]")));
        ((JavascriptExecutor) driver).executeScript("arguments[0].scrollIntoView({block: 'center'});", takeActionButton);
        Thread.sleep(300);
        takeActionButton.click();
        System.out.println("Clicked TAKE ACTION button");
    }

    private void clickTakeActionButton2(WebDriver driver, WebDriverWait wait) throws InterruptedException {
        Thread.sleep(1000); // Add this line
        WebElement takeActionButton = wait.until(ExpectedConditions.elementToBeClickable(
                By.xpath("//button[contains(@class, 'submit-bar') and .//header[normalize-space()='TAKE ACTION']]")));
        ((JavascriptExecutor) driver).executeScript("arguments[0].scrollIntoView({block: 'center'});", takeActionButton);
        Thread.sleep(300);
        takeActionButton.click();
        System.out.println("Clicked TAKE ACTION button");
    }


    private void clickForward(WebDriver driver, WebDriverWait wait) throws InterruptedException {
        WebElement forwardOption = wait.until(ExpectedConditions.elementToBeClickable(
                By.xpath("//div/p[text()='Forward']")));
        ((JavascriptExecutor) driver).executeScript("arguments[0].click();", forwardOption);
        Thread.sleep(2000);
        System.out.println("Clicked Forward option");
    }

    private void selectDropdownFirstOption(WebDriver driver, WebDriverWait wait) throws InterruptedException {
        // Click dropdown to open
        WebElement dropdown = wait.until(ExpectedConditions.elementToBeClickable(
                By.cssSelector("div.employee-select-wrap svg.cp")));
        dropdown.click();
        Thread.sleep(1000);
        
        // Select first option from dropdown
        WebElement optionsContainer = wait.until(ExpectedConditions.visibilityOfElementLocated(
                By.cssSelector("div.options-card")));
        WebElement firstOption = optionsContainer.findElement(
                By.cssSelector("div.profile-dropdown--item:first-child"));
        firstOption.click();
        System.out.println("Selected first option from dropdown");
        Thread.sleep(500);
    }

    private void fillComments(WebDriver driver, WebDriverWait wait, String comment) throws InterruptedException {
        WebElement commentsField = wait.until(ExpectedConditions.visibilityOfElementLocated(
                By.name("comments")));
        commentsField.clear();
        commentsField.sendKeys(comment);
        Thread.sleep(300);
        System.out.println("Filled comments: " + comment);
    }

    private void clickForwardButton(WebDriver driver, WebDriverWait wait) throws InterruptedException {
        WebElement forwardButton = wait.until(ExpectedConditions.elementToBeClickable(
                By.xpath("//button[@type='submit'][@form='modal-action']//h2[text()='Forward']/..")));
        ((JavascriptExecutor) driver).executeScript("arguments[0].click();", forwardButton);
        Thread.sleep(1000);
        System.out.println("Clicked Forward button");
    }

    private void approveStep(WebDriver driver, WebDriverWait wait) throws InterruptedException {
        clickTakeActionButton(driver, wait);
        clickApprove(driver, wait);
        fillComments(driver, wait, "Approved");
        clickApproveButton(driver, wait);
    }

    private void clickApprove(WebDriver driver, WebDriverWait wait) throws InterruptedException {
        Thread.sleep(1000);
        WebElement approveOption = wait.until(ExpectedConditions.elementToBeClickable(
                By.xpath("//div/p[text()='Approve']")));
        ((JavascriptExecutor) driver).executeScript("arguments[0].click();", approveOption);
        System.out.println("Clicked Approve option");
        Thread.sleep(500);
    }

    private void clickApproveButton(WebDriver driver, WebDriverWait wait) throws InterruptedException {
        WebElement approveButton = wait.until(ExpectedConditions.elementToBeClickable(
                By.xpath("//button[@type='submit'][@form='modal-action']//h2[text()='Approve']/..")));
        ((JavascriptExecutor) driver).executeScript("arguments[0].click();", approveButton);
        Thread.sleep(1000);
        System.out.println("Clicked Approve button");
    }

    private void collectFeesStep(WebDriver driver, WebDriverWait wait) throws InterruptedException {
        clickTakeActionButton(driver, wait);
        clickCollectFees(driver, wait);
        fillPayerMobile(driver, wait);
    }

    private void clickCollectFees(WebDriver driver, WebDriverWait wait) throws InterruptedException {
        Thread.sleep(1000);
        WebElement collectFeesOption = wait.until(ExpectedConditions.elementToBeClickable(
                By.xpath("//div/p[text()='Collect Fees']")));
        ((JavascriptExecutor) driver).executeScript("arguments[0].click();", collectFeesOption);
        System.out.println("Clicked Collect Fees option");
        Thread.sleep(500);
    }

    private void fillPayerMobile(WebDriver driver, WebDriverWait wait) throws InterruptedException {
        Thread.sleep(1000);
        WebElement payerMobileInput = wait.until(ExpectedConditions.visibilityOfElementLocated(
                By.name("payerMobile")));
        payerMobileInput.clear();
        payerMobileInput.sendKeys("9999999999");
        System.out.println("Filled Payer Mobile: 9999999999");
        Thread.sleep(500);
        
        // Click Collect Payment button
        clickCollectPaymentButton(driver, wait);
    }

    private void clickCollectPaymentButton(WebDriver driver, WebDriverWait wait) throws InterruptedException {
        WebElement collectPaymentButton = wait.until(ExpectedConditions.elementToBeClickable(
                By.xpath("//button[@type='submit']//header[text()='Collect Payment']/..")));
        ((JavascriptExecutor) driver).executeScript("arguments[0].scrollIntoView({block: 'center'});", collectPaymentButton);
        Thread.sleep(300);
        collectPaymentButton.click();
        System.out.println("Clicked Collect Payment button");
        Thread.sleep(1000);
    }
}
