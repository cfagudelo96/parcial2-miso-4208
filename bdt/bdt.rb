require 'open3'

MUTANTS_FOLDER = '/Users/cfagudelo/Documents/Projects/parcial2'.freeze
ADB_FOLDER = '/Users/cfagudelo/Library/Android/sdk/platform-tools'.freeze

APP_PACKAGE_NAME = 'com.evancharlton.mileage'.freeze
APP_DECODED_FOLDER = "./#{APP_PACKAGE_NAME}_3110".freeze
APK_NAME = "#{APP_PACKAGE_NAME}_3110.apk".freeze

def get_mutant_folder(index)
  "#{MUTANTS_FOLDER}/#{APP_PACKAGE_NAME}-mutant#{index}"
end

def get_screenshots_folder(index)
  "./screenshots/mutant#{index}"
end

def uninstall_app(mutant)
  File.delete("./#{APK_NAME}")
  FileUtils.mv(Dir['./*.png'], get_screenshots_folder(mutant))
end

def install_mutant_apk(mutant)
  FileUtils.cp("#{get_mutant_folder(mutant)}/#{APK_NAME}", './')
  FileUtils.mkdir(get_screenshots_folder(mutant))
  modify_apk_for_calabash
  system("calabash-android resign #{APK_NAME}")
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

def execute_calabash_tests(mutant)
  stdout, stderr, status = Open3.capture3("calabash-android run #{APK_NAME}")
  return if status.success?

  File.open("./bdt-reports/mutant#{mutant}-#{Time.now.to_i}.txt", 'w') do |file|
    file.write(stdout)
    file.write(stderr)
  end
end

(0..5000).each do |i|
  next unless File.directory?(get_mutant_folder(i))

  install_mutant_apk(i)
  execute_calabash_tests(i)
  uninstall_app(i)
end
