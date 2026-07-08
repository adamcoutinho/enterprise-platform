package com.main.ep.rack.db.postgres.table

import com.main.ep.core.domain.Customer

fun CustomerTable.toDomain() = Customer(
    userName = this.userName,
    password = this.password
)

fun Customer.toTable() = CustomerTable(
    userName = this.userName,
    password = this.password
)
