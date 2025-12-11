package org.upyog.Automation.Utils;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

public class ConfigReader {
    private static final Properties props = new Properties();

    static {
        try (InputStream input = ConfigReader.class.getClassLoader().getResourceAsStream("application.properties")) {
            if (input == null) {
                throw new RuntimeException("Unable to find application.properties");
            }
            props.load(input);
        } catch (IOException ex) {
            throw new RuntimeException("Failed to load application.properties", ex);
        }
    }

    public static String get(String key) {
        return props.getProperty(key);
    }
}
