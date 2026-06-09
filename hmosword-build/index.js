const fs = require('fs');
const path = require('path');
const JSON5 = require('json5');
const { exec } = require('child_process');

const outputDir = path.resolve(__dirname, '../submodules');
const mockDir = path.resolve(__dirname, './config/mock.json');

const excludeSample = [''];

function readJson5File(filePath) {
  try {
    const content = fs.readFileSync(filePath, 'utf-8');
    return JSON5.parse(content);
  } catch (error) {
    console.error(`Error reading/parsing ${filePath}:`, error.message);
    return null;
  }
}

function writeJson5File(filePath, data) {
  try {
    fs.writeFileSync(filePath, JSON5.stringify(data, null, 2));
    return true;
  } catch (error) {
    console.error(`Error writing ${filePath}:`, error.message);
    return false;
  }
}

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
  const sampleName = moduleName ? substringFromStartToEnd(moduleName, 6) :
    path.basename(originalUrl, path.extname(originalUrl)).replace(/\/$/, '').replace(/-/g, '');
  const samplePath = `${outputDir}/${sampleName}`;
  console.info(samplePath);
  const isEmptyConfig = !moduleName || !abilityName;
  if (fs.existsSync(samplePath) && fs.readdirSync(samplePath).length > 0) {
    console.info(`Sample ${sampleName} already exists, skipping...`);
    if (isEmptyConfig) {
      processSampleWithoutConfig(samplePath, sampleName);
    } else {
      processSample(samplePath, sampleName, moduleName, abilityName);
    }
    return;
  } else if (fs.existsSync(samplePath) && fs.readdirSync(samplePath).length === 0) {
    fs.rmSync(samplePath, { recursive: true });
  }
  exec(`git clone -b ${branch} ${originalUrl} ${samplePath}`, (error, _stdout, stderr) => {
    if (error) {
      console.error(`${sampleName} failed to download: ${error}`);
      return;
    }
    console.log(`${sampleName} downloaded successfully: ${stderr}`);
    if (isEmptyConfig) {
      processSampleWithoutConfig(samplePath, sampleName);
    } else {
      processSample(samplePath, sampleName, moduleName, abilityName);
    }
  })
}

function processSampleWithoutConfig(samplePath, sampleName) {
  const cloneSamples = [];
  const addedModuleNames = new Set();
  
  function findModuleJson5(dir, relativePath = '') {
    const items = fs.readdirSync(dir);
    
    for (const item of items) {
      const itemPath = path.join(dir, item);
      const itemRelativePath = relativePath ? `${relativePath}/${item}` : item;
      const stat = fs.statSync(itemPath);
      
      if (stat.isDirectory()) {
        findModuleJson5(itemPath, itemRelativePath);
      } else if (item === 'module.json5') {
        if (itemPath.includes('ohosTest')) {
          continue;
        };
        const moduleJsonData = readJson5File(itemPath);
        if (!moduleJsonData) continue;
        
        if (moduleJsonData.module && moduleJsonData.module.name && !addedModuleNames.has(moduleJsonData.module.name)) {
          addedModuleNames.add(moduleJsonData.module.name);
          
          if (moduleJsonData.module.type === 'entry') {
            moduleJsonData.module.type = 'feature';
            moduleJsonData.module.deliveryWithInstall = false;
            writeJson5File(itemPath, moduleJsonData);
          }
          
          const moduleDir = path.dirname(path.dirname(path.dirname(itemRelativePath)));
          cloneSamples.push({
            name: moduleJsonData.module.name,
            srcPath: `./submodules/${sampleName}/${moduleDir}`,
            targets: [{
              name: "default",
              applyToProducts: ["default"]
            }]
          });
        }
      }
    }
  }
  
  findModuleJson5(samplePath);
  
  if (cloneSamples.length > 0) {
    writeBuildProfile(cloneSamples);
    console.info(`Processed ${sampleName} without config, found ${cloneSamples.length} modules`);
  } else {
    console.info(`No module.json5 found in ${sampleName}`);
  }
}

function processSample(samplePath, sampleName, moduleName, abilityName) {
  const sampleBuildPath = `${samplePath}/build-profile.json5`;

  if (fs.existsSync(path.join(samplePath, 'entry')) && !fs.existsSync(path.join(samplePath, moduleName))) {
    fs.renameSync(
      path.join(samplePath, 'entry'),
      path.join(samplePath, moduleName)
    );
  }

  const ohPackagePath = path.join(samplePath, moduleName, 'oh-package.json5');
  if (!fs.existsSync(ohPackagePath)) {
    console.info(`Sample ${moduleName} has no oh-package.json5, skipping...`);
    return;
  }

  const ohPackageData = readJson5File(ohPackagePath);
  if (!ohPackageData) return;
  
  ohPackageData.name = moduleName;
  writeJson5File(ohPackagePath, ohPackageData);

  const moduleJsonPath = path.join(samplePath, moduleName, 'src/main/module.json5');
  if (fs.existsSync(moduleJsonPath)) {
    const moduleJsonData = readJson5File(moduleJsonPath);
    if (moduleJsonData) {
      const { module } = moduleJsonData;
      module.name = moduleName;
      module.type = 'feature';
      module.deliveryWithInstall = false;
      module.abilities[0].name = abilityName;
      module.abilities[0].exported = false;
      writeJson5File(moduleJsonPath, moduleJsonData);
    }
  } else {
    console.info(`Sample ${moduleName} has no module.json5, skipping...`);
  }

  if (!fs.existsSync(sampleBuildPath)) return;

  const sampleBuildData = readJson5File(sampleBuildPath);
  if (!sampleBuildData) return;

  const cloneSamples = [];
  const needModules = sampleBuildData.modules.map(module => {
    if (module.name === 'entry') {
      cloneSamples.push({
        "name": moduleName, "srcPath": `./submodules/${sampleName}/${moduleName}`, "targets": [{
          "name": "default",
          "applyToProducts": ["default"]
        }]
      });
      return moduleName;
    } else {
      cloneSamples.push({
        "name": module.name, "srcPath": `./submodules/${sampleName}/${module.name}`
      });
      return module.name;
    }
  });
  writeBuildProfile(cloneSamples);
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
  const buildProfilePath = path.resolve(__dirname, '../build-profile.json5');
  const buildProfileData = readJson5File(buildProfilePath);
  if (!buildProfileData) return;

  console.info('写入build-profile.json5配置...');
  const buildModules = buildProfileData.modules.map(item => item.name);
  cloneSamples.forEach((sample) => {
    if (!buildModules.includes(sample.name)) {
      buildProfileData.modules.push(sample);
    }
  });
  writeJson5File(buildProfilePath, buildProfileData);
}

// 工具函数
function substringFromStartToEnd(str, n) {
  if (typeof str !== 'string' || n < 0 || n > str.length) {
    return str;
  }
  return str.slice(0, -n);
}

readMock();