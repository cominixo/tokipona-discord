require('fs')
  .readdirSync(__dirname)
  .filter(file => file !== 'index.js')
  .forEach(filename => {
    if (filename != "timestamps.json") {
        exports['en-GB'] = require(`${__dirname}/${filename}`);
        exports['en-US'] = require(`${__dirname}/${filename}`);
    }
  });
