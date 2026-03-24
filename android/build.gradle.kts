import org.jetbrains.kotlin.gradle.dsl.JvmTarget

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

subprojects {
    afterEvaluate {
        if (project.hasProperty("android")) {
            val android = project.extensions.getByName("android")
            if (android is com.android.build.gradle.BaseExtension) {
                android.compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_17
                    targetCompatibility = JavaVersion.VERSION_17
                }
            }
        }
        project.tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
            compilerOptions {
                jvmTarget.set(JvmTarget.JVM_17)
            }
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
}
subprojects {
    project.evaluationDependsOn(":app")
}


subprojects {
    val patchManifest: Action<Project> = Action {
        if (project.hasProperty("android")) {
            val android = project.extensions.getByName("android")
            // Force compileSdk 36 for all subprojects (fixes isar_flutter_libs lStar issue)
            if (android is com.android.build.gradle.BaseExtension) {
                if (android.compileSdkVersion != "android-36") {
                    android.compileSdkVersion(36)
                }
            }
            
            if (android is com.android.build.gradle.LibraryExtension) {
                val mainSourceSet = android.sourceSets.getByName("main")
                val originalManifest = mainSourceSet.manifest.srcFile

                // Extract package from manifest and use as namespace if needed
                if (android.namespace.isNullOrEmpty() && originalManifest.exists()) {
                    val manifestText = originalManifest.readText()
                    val packageMatch = Regex("""package="([^"]*)"""").find(manifestText)
                    android.namespace = packageMatch?.groupValues?.get(1)
                        ?: "com.example.${project.name.replace("-", "_")}"
                }

                // Strip package attribute from manifest to satisfy AGP 8.11.1
                if (originalManifest.exists()) {
                    val content = originalManifest.readText()
                    if (content.contains("package=")) {
                        val patchedDir = project.layout.buildDirectory.dir("patched-manifest").get().asFile
                        patchedDir.mkdirs()
                        val patchedManifest = File(patchedDir, "AndroidManifest.xml")
                        patchedManifest.writeText(content.replace(Regex("""\s*package="[^"]*""""), ""))
                        mainSourceSet.manifest.srcFile(patchedManifest)
                    }
                }
            }
        }
    }
    if (project.state.executed) {
        patchManifest.execute(project)
    } else {
        afterEvaluate(patchManifest)
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
