package com.microsoft.springbootadmin;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import de.codecentric.boot.admin.server.config.EnableAdminServer;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.context.annotation.Configuration;

@SpringBootApplication
@Configuration
@EnableAutoConfiguration // Use a discovery service instead of Spring Boot Admin Clinet. The rest is done by our AutoConfiguration.
@EnableDiscoveryClient  // Enables the service to register with a discovery service
@EnableAdminServer
public class SpringbootadminApplication {

	public static void main(String[] args) {
		SpringApplication.run(SpringbootadminApplication.class, args);
	}

}
