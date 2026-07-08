package com.main.ep.core.service.db

import com.main.ep.core.domain.Customer

interface CustomerDbService {
    fun save(customer:Customer):Customer?
}