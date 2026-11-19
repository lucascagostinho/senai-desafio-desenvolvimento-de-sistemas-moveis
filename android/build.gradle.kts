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
// Compatibilidade dos plugins nas versões do enunciado (DV02).
// Plugins antigos (ex.: map_launcher 2.x, geocoding_android 3.x) foram feitos
// para um Android Gradle Plugin antigo: não declaram `namespace` (obrigatório no
// AGP 8+) e compilam contra APIs antigas, que dependências AndroidX atuais
// recusam. Aqui completamos esses dois pontos sem trocar a versão das libs.
subprojects {
    plugins.withId("com.android.library") {
        extensions.configure<com.android.build.api.variant.LibraryAndroidComponentsExtension> {
            finalizeDsl { android ->
                if (android.namespace == null) {
                    val manifest = file("src/main/AndroidManifest.xml")
                    val pkg = if (manifest.exists()) {
                        Regex("package=\"([^\"]+)\"").find(manifest.readText())?.groupValues?.get(1)
                    } else null
                    android.namespace = pkg ?: project.group.toString()
                }
                if ((android.compileSdk ?: 0) < 36) {
                    android.compileSdk = 36
                }
                // Java e Kotlin precisam gerar bytecode para a mesma versão da JVM.
                android.compileOptions.sourceCompatibility = JavaVersion.VERSION_17
                android.compileOptions.targetCompatibility = JavaVersion.VERSION_17
            }
        }
    }
    plugins.withId("org.jetbrains.kotlin.android") {
        tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
            compilerOptions.jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
