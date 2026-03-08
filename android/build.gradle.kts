allprojects {
    repositories {
        google()
        mavenCentral()
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
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    val setupNamespace = {
        val android = project.extensions.findByName("android") as? com.android.build.gradle.BaseExtension
        if (android != null && android.namespace == null) {
            val packageName = project.group.toString().replace(":", ".")
            if (packageName.isNotEmpty()) {
                android.namespace = packageName
            } else {
                android.namespace = "com.example.${project.name.replace("-", "_")}"
            }
        }
    }

    if (project.state.executed) {
        setupNamespace()
    } else {
        project.afterEvaluate {
            setupNamespace()
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
