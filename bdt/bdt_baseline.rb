require 'open3'

BASELINE_APK =
  '/Users/cfagudelo/Documents/Projects/parcial2/baseline/com.evancharlton.mileage_3110.apk'.freeze
ADB_FOLDER = '/Users/cfagudelo/Library/Android/sdk/platform-tools'.freeze

APP_PACKAGE_NAME = 'com.evancharlton.mileage'.freeze
APP_DECODED_FOLDER = "./#{APP_PACKAGE_NAME}_3110".freeze
APK_NAME = "#{APP_PACKAGE_NAME}_3110.apk".freeze

def uninstall_app
  File.delete("./#{APK_NAME}")
  system("#{ADB_FOLDER}/adb uninstall #{APP_PACKAGE_NAME}")
end

def install_apk
  FileUtils.cp(BASELINE_APK.to_s, './')
  modify_apk_for_calabash
  system("calabash-android resign #{APK_NAME}")
  system("#{ADB_FOLDER}/adb install -r ./#{APK_NAME}")
end

def modify_apk_for_calabash
  system("java -jar apktool_2.3.4.jar d #{APK_NAME}")
  FileUtils.cp_r(
    './ModifiedAndroidManifest.xml',
    "#{APP_DECODED_FOLDER}/AndroidManifest.xml",
    remove_destination: true
  )
  File.delete("./#{APK_NAME}")
  system("java -jar apktool_2.3.4.jar b #{APP_DECODED_FOLDER}")
  FileUtils.cp("#{APP_DECODED_FOLDER}/dist/#{APK_NAME}", './')
  FileUtils.remove_dir(APP_DECODED_FOLDER, force: true)
end

def execute_tests
  stdout, stderr, status = Open3.capture3("calabash-android run #{APK_NAME}")
  return if status.success?

  File.open("./bdd-reports/baseline-#{Time.now.to_i}.txt", 'w') do |file|
    file.write(stdout)
    file.write(stderr)
  end
end

install_apk
execute_tests
uninstall_app
