/*jshint esversion: 6 */

const resemble = require('resemblejs');
const fs = require('fs');
const find = require('find');

const differenceThreshold = 0.1;

function getMutantScreenshotsFolder(mutant) {
  return `../bdt/screenshots/mutant${mutant}`;
}

function getDiff(mutant) {
  find.file(getMutantScreenshotsFolder(mutant), mutantScreenshots => {
    mutantScreenshots.forEach(mutantScreenshot => {
      const filenameSplit = mutantScreenshot.split('/');
      const filename = filenameSplit[filenameSplit.length - 1];
      const baselineScreenshot = `../bdt/screenshots/baseline/${filename}`;

      resemble(mutantScreenshot)
        .compareTo(baselineScreenshot)
        .ignoreLess()
        .onComplete(function (data) {
          const misMatchPercentage = data.misMatchPercentage;
          if (parseFloat(misMatchPercentage) > differenceThreshold) {
            console.log(`Error en ${filename} de mutante ${mutant}`);
            const filenameWithoutExtension = filename.split('.')[0];
            fs.writeFileSync(
              `${getMutantScreenshotsFolder(mutant)}/${filenameWithoutExtension}-comparison.png`,
              data.getBuffer()
            );
          }
          console.log(`Procesa mutante ${mutant}`);
        });
    });
  });
}

function execute() {
  for (let mutant = 0; mutant < 5000; mutant++) {
    if (fs.existsSync(getMutantScreenshotsFolder(mutant))) {
      getDiff(mutant);
    }
  }
}

execute();
