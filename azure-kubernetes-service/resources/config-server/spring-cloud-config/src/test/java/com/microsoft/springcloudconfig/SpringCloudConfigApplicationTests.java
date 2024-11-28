package com.microsoft.springcloudconfig;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;

@SpringBootTest
@TestPropertySource(properties = {
	"spring.cloud.config.server.git.uri=https://github.com/test/test-repo.git",
})
class SpringCloudConfigApplicationTests {

	@Test
	void contextLoads() {
	}

}
