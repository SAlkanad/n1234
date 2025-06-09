plugins {
    // لا شيء هنا لأن هذا ملف المشروع وليس ملف التطبيق
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ✅ تعيين build directory مخصص
// val newBuildDir = rootProject.layout.buildDirectory.dir("../../build")
// rootProject.layout.buildDirectory.set(newBuildDir)

// // ✅ تعيين build directory للموديولات باستثناء flutter_plugin_android_lifecycle
// subprojects {
//     if (project.name != "flutter_plugin_android_lifecycle") {
//         val newSubprojectBuildDir = newBuildDir.map { it.dir(project.name) }
//         project.layout.buildDirectory.set(newSubprojectBuildDir)
//     }
// }

// ✅ تأكد من تقييم app أولاً
subprojects {
    project.evaluationDependsOn(":app")
}

// ✅ مهمة clean
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
