package com.main.ep.rack.v1.customers.com.main.ep.rack.v1.customers.dto

import com.fasterxml.jackson.annotation.JsonProperty

data class CustomersFormRequest(
    @field:JsonProperty("user_name")
    var userName:String?=null,
    @field:JsonProperty("password")
    var password:String?=null
)