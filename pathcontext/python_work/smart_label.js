// const MongoClient = require('mongodb').MongoClient;
const fs = require('fs');
const path = require('path');
const util = require('util');
const readline = require('readline');
const execFile = util.promisify(require('child_process').exec);

// let count = 0;
// const writeStream = fs.createWriteStream('/Users/manisuec/out_new.json');

// const rl = readline.createInterface({
//   input: fs.createReadStream('/Users/manisuec/out.json'),
// });

// rl.on('line', (input) => {
//   const obj = JSON.parse(input);
//   obj._id = ++count;

//   writeStream.write(JSON.stringify(obj) + '\n');
// });

const readFile = util.promisify(fs.readFile);
const writeFile = util.promisify(fs.writeFile);

// const getClient = async () => {
//  const client = new MongoClient('mongodb://localhost:27017');
//  await client.connect();

//  return client;
// };

const getAllFiles = function (dirPath, arrayOfFiles) {
  files = fs.readdirSync(dirPath);

  arrayOfFiles = arrayOfFiles || [];

  files.forEach(function (file) {
    if (fs.statSync(dirPath + '/' + file).isDirectory()) {
      arrayOfFiles = getAllFiles(dirPath + '/' + file, arrayOfFiles);
    } else {
      arrayOfFiles.push(path.join(dirPath, '/', file));
    }
  });

  return arrayOfFiles;
};

const run = async () => {
  const outPath = 'F:/Blockchain/solidity_dataset_work/4k_smartcheck_txt';
  let count = 0;

  try {
    // const dbClient = await getClient();
    const fileArr = getAllFiles(
      path.resolve('F:/Blockchain/solidity_dataset_work/4k_dataset'),
    );

    // console.log(fileArr.length);

    // const fileContent = await readFile(path.resolve(`${fileArr[0]}`), 'utf8');
    // console.log(fileContent);

    for (const file of fileArr) {
      try {
        // const fileContent = await readFile(file, 'utf8');
        const fileName = path.basename(file, '.sol');
        console.log(++count, fileName);
        const { stdout } = await execFile(`smartcheck -p ${path.resolve(file)}`, {maxBuffer: 51200000});
        // console.log(stdout);

        const res = await writeFile(path.resolve(outPath, `${fileName}.txt`), stdout);

        // console.log(fileContent);
        // await dbClient
        //   .db('supriya')
        //   .collection('solidity')
        //   .insertOne({ solidity: fileContent });
      } catch (error) {
        console.log(error);
      }
    }
  } catch (error) {
    console.log(error);
  }
};

run();