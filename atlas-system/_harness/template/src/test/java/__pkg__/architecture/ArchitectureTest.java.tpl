package {{MODULE_PACKAGE}}.architecture;

import com.tngtech.archunit.junit.AnalyzeClasses;
import com.tngtech.archunit.junit.ArchTest;
import com.tngtech.archunit.junit.ArchTests;
import sharedkernel.archunit.SharedKernelRules;

@AnalyzeClasses(packages = "{{MODULE_PACKAGE}}")
class ArchitectureTest {

    @ArchTest
    static final ArchTests sharedRules = ArchTests.in(SharedKernelRules.class);
}
