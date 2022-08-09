package com.vmware.acme.catalog;

import io.restassured.RestAssured;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.web.server.LocalServerPort;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.equalTo;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@Testcontainers
class CatalogApplicationTests {

    @LocalServerPort
    private int serverPort;

    @Container
    private static final PostgreSQLContainer postgres = new PostgreSQLContainer("postgres:14.4-alpine3.16");

    @DynamicPropertySource
    static void sqlserverProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
    }

    @BeforeEach
    void before() {
        RestAssured.port = serverPort;
    }

    @Test
    void listAllProducts() {
        given()
                .get("/products")
                .then()
                .assertThat()
                .body("data.size()", equalTo(8));
    }

    @Test
    void findProductById() {
        given()
                .get("/products/533445d-530e-4a76-9398-5d16713b827b")
                .then()
                .assertThat()
                .body("data.description", equalTo("Magic Yoga Mat!"));
    }

}
