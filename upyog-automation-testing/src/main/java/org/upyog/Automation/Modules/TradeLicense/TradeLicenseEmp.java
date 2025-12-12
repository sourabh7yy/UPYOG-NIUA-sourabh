package org.upyog.Automation.Modules.TradeLicense;


import org.openqa.selenium.By;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.interactions.Actions;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;
import org.springframework.stereotype.Component;
import java.util.List;

import javax.annotation.PostConstruct;
import java.time.Duration;
import java.util.HashMap;
import java.util.Map;

//@Component
public class TradeLicenseEmp {

    //@PostConstruct
    public void TradeLicenseEmpReg(){



        System.out.println("New Pet Registration");
        System.setProperty("webdriver.chrome.driver", "/usr/local/bin/chromedriver");




        ChromeOptions options = new ChromeOptions();
        options.addArguments("--remote-allow-origins=*");
        options.addArguments("--disable-blink-features=AutomationControlled");
        options.addArguments("--start-maximized");

        options.addArguments("--disable-autofill");
        options.addArguments("--disable-autofill-keyboard-accessory-view");
        options.addArguments("--disable-full-form-autofill-ios");
        options.addArguments("--disable-save-password-bubble");

        Map<String, Object> prefs = new HashMap<>();
        prefs.put("autofill.address_enabled", false);
        prefs.put("autofill.profile_enabled", false);
        options.setExperimentalOption("prefs", prefs);


        WebDriver driver = new ChromeDriver(options);
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(30));

        try {

            System.out.println("New Trade License Registration");


            driver.get("https://niuatt.niua.in/digit-ui/employee/user/login");
            driver.manage().window().maximize();
            System.out.println("Open the Login Portal");

            // Wait for the username input field to be visible and enter the username
            WebElement usernameInput = wait.until(
                    ExpectedConditions.visibilityOfElementLocated(By.name("username"))
            );
            usernameInput.clear();
            usernameInput.sendKeys("TLEMP"); // Replace with actual username

            // Wait for the password input field to be visible and enter the password
            WebElement passwordInput = wait.until(
                    ExpectedConditions.visibilityOfElementLocated(By.name("password"))
            );
            passwordInput.clear();
            passwordInput.sendKeys("eGov@123"); // Replace with actual password

            System.out.println("filled username and password ");

            // 1. Wait for the city dropdown input to be clickable
            WebElement cityDropdownInput = wait.until(
                    ExpectedConditions.elementToBeClickable(By.cssSelector("div.select input.employee-select-wrap--elipses"))
            );

            // 2. Click the SVG (dropdown arrow) to open the dropdown
            WebElement cityDropdownContainer = driver.findElement(By.cssSelector("div.select"));
            WebElement cityDropdownArrow = cityDropdownContainer.findElement(By.tagName("svg"));
            cityDropdownArrow.click(); // Or use Actions for reliability

            // Alternatively, using Actions for more robust clicking:
            Actions actions = new Actions(driver);
            actions.moveToElement(cityDropdownArrow).click().perform();

            // 3. Wait for the dropdown options to appear
            WebElement dropdownOptions = wait.until(
                    ExpectedConditions.visibilityOfElementLocated(By.cssSelector("div.options-card"))
            );

            // 4. Select the first option (City A)
            WebElement firstCityOption = dropdownOptions.findElement(By.cssSelector(".profile-dropdown--item:first-child"));
            actions.moveToElement(firstCityOption).click().perform();


            // Wait for the Continue button to be clickable
            WebElement continueButton = wait.until(
                    ExpectedConditions.elementToBeClickable(
                            By.xpath("//button[contains(@class, 'submit-bar') and .//header[text()='Continue']]")
                    )
            );

            // Scroll to the button (optional, improves reliability)
            ((JavascriptExecutor) driver).executeScript("arguments[0].scrollIntoView(true);", continueButton);

            // Click the button
            continueButton.click();


            WebElement newApplicationTl = wait.until(
                    ExpectedConditions.visibilityOfElementLocated(
                            By.xpath("//a[contains(@href, '/digit-ui/employee/tl/new-application') and contains(normalize-space(.), 'New Application')]")
                    )
            );
            ((JavascriptExecutor) driver).executeScript("arguments[0].scrollIntoView({block: 'center'});", newApplicationTl);
            Thread.sleep(300);
            ((JavascriptExecutor) driver).executeScript("arguments[0].click();", newApplicationTl);
            System.out.println("Clicked New Tl Application  .");

            // Locate the input field using its class attribute
            WebElement inputField = driver.findElement(By.cssSelector("input.employee-card-input"));

            // Autofill with "Institute"
            inputField.sendKeys("Institute");


            Thread.sleep(3000);




            //--------------DROPDOWNS-----------------























        }catch (Exception e){
        System.out.println("Exception in Tl Registration");
        }finally {
        //driver.quit();
    }
  }
}

