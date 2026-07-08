package com.main.ep.rack.db.postgres.config

import com.main.ep.core.service.transaction.ExecuteTransactionManager
import org.springframework.stereotype.Component
import org.springframework.transaction.annotation.Transactional
import java.util.function.Supplier
@Component
open class ExecuteTransactionFramework: ExecuteTransactionManager {
    @Transactional
    override fun execute(runnable: Runnable) {
     runnable.run()
    }

    @Transactional
    override fun <T> execute(supplier: Supplier<T>): T {
        return supplier.get()
    }

}