package org.upyog.Automation.Utils;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.time.Duration;
import java.util.HashMap;
import java.util.Map;

public class DriverFactory {

    public static WebDriver createChromeDriver() {
        System.setProperty("webdriver.chrome.driver", ConfigReader.get("chrome.driver.path"));

        ChromeOptions options = new ChromeOptions();
        // Add all chrome options from properties
        for (int i = 1; ; i++) {
            String opt = ConfigReader.get("chrome.option." + i);
            if (opt == null) break;
            options.addArguments(opt);
        }

        // Set Chrome prefs
        Map<String, Object> prefs = new HashMap<>();
        prefs.put("autofill.address_enabled", Boolean.parseBoolean(ConfigReader.get("chrome.prefs.autofill.address_enabled")));
        prefs.put("autofill.profile_enabled", Boolean.parseBoolean(ConfigReader.get("chrome.prefs.autofill.profile_enabled")));
        options.setExperimentalOption("prefs", prefs);

        return new ChromeDriver(options);
    }

    public static WebDriverWait createWebDriverWait(WebDriver driver) {
        int timeout = Integer.parseInt(ConfigReader.get("webdriver.wait.timeout"));
        return new WebDriverWait(driver, Duration.ofSeconds(timeout));
    }
}
