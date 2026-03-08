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
        if (android != null) {
            if (android.namespace == null) {
                val packageName = project.group.toString().replace(":", ".")
                if (packageName.isNotEmpty()) {
                    android.namespace = packageName
                } else {
                    android.namespace = "com.example.${project.name.replace("-", "_")}"
                }
            }
            
            // Fix for flutter_vibrate 1.3.0 and similar plugins with hardcoded package in AndroidManifest.xml
            // when using newer Android Gradle Plugin versions
            android.sourceSets.getByName("main").manifest.srcFile("src/main/AndroidManifest.xml")
            project.tasks.withType(com.android.build.gradle.tasks.ProcessLibraryManifest::class.java).configureEach {
                doLast {
                    val manifestFile = manifestOutputFile.get().asFile
                    if (manifestFile.exists()) {
                        var content = manifestFile.readText()
                        if (content.contains("package=\"flutter.plugins.vibrate\"")) {
                            content = content.replace("package=\"flutter.plugins.vibrate\"", "")
                            manifestFile.writeText(content)
                        }
                    }
                }
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
