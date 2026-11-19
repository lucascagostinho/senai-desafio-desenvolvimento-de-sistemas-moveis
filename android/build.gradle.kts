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
// Compatibilidade dos plugins nas versões do enunciado (DV11).
// O geocoding 2.x (geocoding_android 3.3.1) e o map_launcher 3.x foram feitos
// para um Android antigo: compilam contra o Android 33, e dependências AndroidX
// atuais exigem 34 ou mais; e geram Java 1.8 enquanto o Kotlin gera para a JVM
// atual, combinação que o Gradle recusa.
// - compileSdk: só sobe para quem estiver abaixo de 36 (nunca rebaixa ninguém).
// - Java/Kotlin 17: só nas duas libs antigas que comprovadamente precisam.
// Nenhuma versão de lib muda.
val minCompileSdk = 36 // o mesmo do app (flutter.compileSdkVersion no Flutter 3.50)
val libsComJavaAntigo = setOf("geocoding_android", "map_launcher")
subprojects {
    plugins.withId("com.android.library") {
        extensions.configure<com.android.build.api.variant.LibraryAndroidComponentsExtension> {
            finalizeDsl { android ->
                if ((android.compileSdk ?: 0) < minCompileSdk) {
                    android.compileSdk = minCompileSdk
                }
                if (project.name in libsComJavaAntigo) {
                    android.compileOptions.sourceCompatibility = JavaVersion.VERSION_17
                    android.compileOptions.targetCompatibility = JavaVersion.VERSION_17
                }
            }
        }
    }
    if (project.name in libsComJavaAntigo) {
        plugins.withId("org.jetbrains.kotlin.android") {
            tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
                compilerOptions.jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
            }
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
