(function() {
  const shelljs = require('shelljs');
  const mongoose = require('mongoose');

  mongoose.connect('mongodb://localhost:27017/parcial2', { useNewUrlParser: true });

  const db = mongoose.connection;

  db.once('open', async function () {
    const randomTestingErrorSchema = new mongoose.Schema({
      mutant: { type: Number, required: true },
      log: { type: String, required: true },
      seed: { type: Number, required: true }
    });

    const RandomTestingError = mongoose.model('RandomTestingError', randomTestingErrorSchema);

    const mutantsFolder = '/Users/cfagudelo/Documents/Projects/parcial2';
    const adbFolder = '/Users/cfagudelo/Library/Android/sdk/platform-tools';
    const apksignerFolder = '/Users/cfagudelo/Library/Android/sdk/build-tools/28.0.3';
    const keystore = `${apksignerFolder}/mykeystore.keystore`

    const appPackageName = 'com.evancharlton.mileage';
    const apkName = `${appPackageName}_3110.apk`

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

    async function runMonkey(mutant) {
      const seed = Math.floor(Math.random() * 100000000) + 1
      const execution = shelljs.exec(`${adbFolder}/adb shell monkey -p ${appPackageName} -s ${seed} --kill-process-after-error ${numberOfEvents}`);
      if (executionHadErrors(execution)) {
        await new RandomTestingError({ mutant: mutant, log: execution.stdout, seed: seed }).save();
      }
    }

    function executionHadErrors(execution) {
      const eventsInjected = parseInt(execution.stdout.match(new RegExp(/Events injected: (\d+)(\D*|$)/))[1]);
      return eventsInjected != numberOfEvents;
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
  });
})();
