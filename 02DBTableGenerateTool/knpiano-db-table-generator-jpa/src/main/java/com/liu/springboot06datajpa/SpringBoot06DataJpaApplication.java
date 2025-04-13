package com.liu.springboot06datajpa;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;

@SpringBootApplication
@EntityScan("com.liu.springboot06datajpa.db_table.table_entity")
public class SpringBoot06DataJpaApplication {

    public static void main(String[] args) {
        SpringApplication.run(SpringBoot06DataJpaApplication.class, args);
    }

}
