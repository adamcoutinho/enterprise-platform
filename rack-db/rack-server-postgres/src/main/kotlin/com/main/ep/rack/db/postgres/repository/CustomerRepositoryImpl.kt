package com.main.ep.rack.db.postgres.repository

import com.main.ep.core.domain.Customer
import com.main.ep.core.service.db.CustomerDbService
import com.main.ep.rack.db.postgres.jparepository.CustomerJpaRepository
import com.main.ep.rack.db.postgres.table.toDomain
import com.main.ep.rack.db.postgres.table.toTable
import org.springframework.stereotype.Repository

@Repository
class CustomerRepositoryImpl(private val customerJpaRepository: CustomerJpaRepository): CustomerDbService {

    override fun save(customer: Customer): Customer? {
      return  this.customerJpaRepository.save(customer.toTable()).toDomain()
    }

}