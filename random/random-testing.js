/*jshint esversion: 6 */

const shelljs = require('shelljs');
const fs = require('fs');

const mutantsFolder = '/Users/cfagudelo/Documents/Projects/parcial2';
const adbFolder = '/Users/cfagudelo/Library/Android/sdk/platform-tools';
const apksignerFolder = '/Users/cfagudelo/Library/Android/sdk/build-tools/28.0.3';
const keystore = `${apksignerFolder}/mykeystore.keystore`;

const appPackageName = 'com.evancharlton.mileage';
const apkName = `${appPackageName}_3110.apk`;

const numberOfExecutions = 5;
const numberOfEvents = 5000;
const numberOfMutants = 5000;

function getMutantFolder(index) {
  return `${mutantsFolder}/${appPackageName}-mutant${index}`;
}

function mutantFolderExists(mutantFolder) {
  return shelljs.test('-d', mutantFolder);
}

function signMutantApk(mutantFolder) {
  shelljs.exec(`${apksignerFolder}/apksigner sign --ks ${keystore} --ks-pass pass:123456 --key-pass pass:123456 --out ${mutantFolder}/signed.apk ${mutantFolder}/${apkName}`);
}

function uninstallApp() {
  shelljs.exec(`${adbFolder}/adb uninstall ${appPackageName}`);
}

function installMutantApk(mutantFolder) {
  signMutantApk(mutantFolder);
  shelljs.exec(`${adbFolder}/adb install -r ${mutantFolder}/signed.apk`);
}

function executionHadErrors(execution) {
  try {
    const eventsInjectedText = execution.stdout.match(new RegExp(/Events injected: (\d+)(\D*|$)/));
    const eventsInjected = parseInt(eventsInjectedText[1]);
    return eventsInjected !== numberOfEvents;
  } catch(e) {
    return true;
  }
}

async function runMonkey(mutant) {
  const seed = Math.floor(Math.random() * 100000000) + 1
  const execution = shelljs.exec(`${adbFolder}/adb shell monkey -p ${appPackageName} -s ${seed} --kill-process-after-error ${numberOfEvents}`);
  if (executionHadErrors(execution)) {
    fs.writeFileSync(`./reports/mutant${mutant}-seed${seed}-${new Date().getTime()}.txt`, execution.stdout);
  }
}

for (let k = 0; k < numberOfExecutions; k++) {
  for (let i = 0; i < numberOfMutants; i++) {
    const mutantFolder = getMutantFolder(i);
    if (mutantFolderExists(mutantFolder)) {
      installMutantApk(mutantFolder);
      runMonkey(i);
      uninstallApp();
    }
  }
}
process.exit();
