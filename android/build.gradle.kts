allprojects {
    repositories {
        google()
        mavenCentral()
    }
    
    configurations.all {
        resolutionStrategy {
            force("androidx.core:core:1.13.1")
            force("androidx.core:core-ktx:1.13.1")
            force("androidx.fragment:fragment:1.6.0")
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    
    // Apply fixes for known package issues
    if (project.name == "isar_flutter_libs") {
        apply(from = rootProject.file("isar_fix.gradle"))
    }
    
    // Disable resource verification for problematic packages
    afterEvaluate {
        if (project.name == "isar_flutter_libs") {
            tasks.withType(com.android.build.gradle.tasks.VerifyLibraryResourcesTask::class.java) {
                enabled = false
            }
        }
    }
    
    project.evaluationDependsOn(":app")
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
