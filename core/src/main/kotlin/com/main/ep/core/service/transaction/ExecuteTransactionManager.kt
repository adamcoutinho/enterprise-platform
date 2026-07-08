package com.main.ep.core.service.transaction

import java.util.function.Supplier

interface ExecuteTransactionManager {

    fun execute(runnable: Runnable)
    fun <T> execute(supplier: Supplier<T>):T
}