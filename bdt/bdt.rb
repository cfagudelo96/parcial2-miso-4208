require 'open3'

MUTANTS_FOLDER = '/Users/cfagudelo/Documents/Projects/parcial2'.freeze
ADB_FOLDER = '/Users/cfagudelo/Library/Android/sdk/platform-tools'.freeze

APP_PACKAGE_NAME = 'com.evancharlton.mileage'.freeze
APK_NAME = "#{APP_PACKAGE_NAME}_3110.apk".freeze

def get_mutant_folder(index)
  "#{MUTANTS_FOLDER}/#{APP_PACKAGE_NAME}-mutant#{index}"
end

def uninstall_app
  File.delete("./#{APK_NAME}")
  system("#{ADB_FOLDER}/adb uninstall #{APP_PACKAGE_NAME}")
end

def install_mutant_apk(mutant_folder)
  FileUtils.cp("#{mutant_folder}/#{APK_NAME}", './')
  system("calabash-android resign #{APK_NAME}")
  system("#{ADB_FOLDER}/adb install -r #{mutant_folder}/#{APK_NAME}")
end

def execute_calabash_tests(mutant)
  stdout, stderr, status = Open3.capture3("calabash-android run #{APK_NAME}")
  return if status.success?

  File.open("./bdd-reports/mutant#{mutant}-#{Time.now.to_i}.txt", 'w') do |file|
    file.write(stdout)
    file.write(stderr)
  end
end

(0..5000).each do |i|
  mutant_folder = get_mutant_folder(i)
  next unless File.directory?(mutant_folder)

  install_mutant_apk(mutant_folder)
  execute_calabash_tests(i)
  uninstall_app
end
