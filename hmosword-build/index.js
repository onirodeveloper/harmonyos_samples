const fs = require('fs');
const path = require('path');
const JSON5 = require('json5');
const { exec } = require('child_process');

const outputDir = path.resolve(__dirname, '../submodules');
const mockDir = path.resolve(__dirname, './config/mock.json');

const excludeSample = [''];

// 获取mock数据
function readMock() {
  const samplesMockFile = fs.readFileSync(mockDir, 'utf-8');
  const samplesMockData = JSON.parse(samplesMockFile).data;
  console.info('正在下载samples到以下目录...');

  samplesMockData.forEach((item) => {
    loadSample(item);
  })
}

function loadSample(sampleInfo) {
  const { moduleName, originalUrl, abilityName, branch } = sampleInfo;
  const sampleName = substringFromStartToEnd(moduleName, 6);
  const samplePath = `${outputDir}/${sampleName}`;
  console.info(samplePath);
  // 排除不需要的sample
  if (excludeSample.includes(moduleName) || originalUrl === '') {
    return;
  }
  // 容错处理
  if (fs.existsSync(samplePath) && fs.readdirSync(samplePath).length > 0) {
    console.info(`Sample ${sampleName} already exists, skipping...`);
    processSample(samplePath, sampleName, moduleName, abilityName);
    return;
  } else if (fs.existsSync(samplePath) && fs.readdirSync(samplePath).length === 0) {
    fs.rmdSync(samplePath, { recursive: true });
  }
  exec(`git clone -b ${branch} ${originalUrl} ${samplePath}`, (error, _stdout, stderr) => {
    if (error) {
      console.error(`${sampleName} failed to download: ${error}`);
      return;
    }
    console.log(`${sampleName} downloaded successfully: ${stderr}`);
    processSample(samplePath, sampleName, moduleName, abilityName);
  })

}

function processSample(samplePath, sampleName, moduleName, abilityName) {
  const sampleBuildPath = `${samplePath}/build-profile.json5`;
  let sampleBuildFile;
  let sampleBuildData;

  // 修改entry目录名,如果有entry
  if (fs.existsSync(path.join(samplePath, 'entry'))) {
    fs.renameSync(
      path.join(samplePath, 'entry'),
      path.join(samplePath, moduleName)
    );
  }

  // 修改oh-package5.json
  const ohPackagePath = path.join(samplePath, moduleName, 'oh-package.json5');
  if (fs.existsSync(ohPackagePath)) {
    let ohPackageData;
    try {
      ohPackageData = JSON5.parse(fs.readFileSync(ohPackagePath, 'utf-8'));
    } catch (error) {
      console.error(`Error read oh-package.json5 for ${moduleName}:`, error);
      return;
    }
    ohPackageData.name = moduleName;
    fs.writeFileSync(ohPackagePath, JSON5.stringify(ohPackageData, null, 2));
  } else {
    console.info(`Sample ${moduleName} has no oh-package.json5, skipping...`);
    return;
  }

  // 修改module.json5
  const moduleJsonPath = path.join(samplePath, moduleName, 'src/main/module.json5');
  if (fs.existsSync(moduleJsonPath)) {
    const moduleJsonData = JSON5.parse(fs.readFileSync(moduleJsonPath, 'utf-8'));
    // 修改module.json5的name字段
    const { module } = moduleJsonData;
    module.name = moduleName;
    module.type = 'feature';
    module.deliveryWithInstall = false;
    module.abilities[0].name = abilityName;
    module.abilities[0].exported = false;
    fs.writeFileSync(moduleJsonPath, JSON5.stringify(moduleJsonData, null, 2));
  } else {
    console.info(`Sample ${moduleName} has no module.json5, skipping...`);
  }

  if (!fs.existsSync(sampleBuildPath)) {
    return;
  }
  try {
    sampleBuildFile = fs.readFileSync(sampleBuildPath, 'utf-8');
    sampleBuildData = JSON5.parse(sampleBuildFile);
  } catch (error) {
    console.error(`Error parsing build-profile.json5 for ${moduleName}:`, error);
    return;
  }
  // 获取需要的模块
  let cloneSamples = [];
  const needModules = sampleBuildData.modules.map(module => {
    if (module.name === 'entry') {
      cloneSamples.push({
        "name": moduleName, "srcPath": `./submodules/${sampleName}/${moduleName}`, "targets": [{
          "name": "default",
          "applyToProducts": [
            "default"
          ]
        }]
      })
      return moduleName;
    } else {
      cloneSamples.push({
        "name": module.name, "srcPath": `./submodules/${sampleName}/${module.name}`
      })
      return module.name;
    }
  });
  writeBuildProfile(cloneSamples);
  // 删除多余目录和文件
  deleteExtraDir(samplePath, needModules);
}

function deleteExtraDir(samplePath, needModules, moduleName) {
  fs.readdir(samplePath, (err, files) => {
    if (err) {
      console.error('读取目录时出错:', err);
      return;
    }
    files.forEach((file) => {
      const filePath = path.join(samplePath, file);
      fs.stat(filePath, (err, stats) => {
        if (err) {
          console.error('获取文件信息时出错:', err);
          return;
        }
        if (stats.isDirectory()) {
          if (!needModules.includes(file)) {
            fs.rmSync(filePath, { recursive: true });
          }
        } else if (stats.isFile()) {
          fs.unlinkSync(filePath);
        }
      });
    });
  });
}

function writeBuildProfile(cloneSamples) {
  let buildProfileData;
  try {
    buildProfileData = JSON5.parse(fs.readFileSync(path.resolve(__dirname, '../build-profile.json5'), 'utf-8'));
  } catch (error) {
    console.error('读取文件build-profile.json5时出错:', error);
  }
  console.info('写入build-profile.json5配置...');
  const buildModules = buildProfileData.modules.map(item => item.name)
  cloneSamples.forEach((sample) => {
    if (buildModules.includes(sample.name)) {
      return;
    }
    buildProfileData.modules.push(sample);
  })
  fs.writeFileSync(
    path.resolve(__dirname, '../build-profile.json5'),
    JSON5.stringify(buildProfileData, null, 2)
  );
}

// 工具函数
function substringFromStartToEnd(str, n) {
  if (typeof str !== 'string' || n < 0 || n > str.length) {
    return str;
  }
  return str.slice(0, -n);
}

readMock();