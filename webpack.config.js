const fs = require('fs');
const path = require('path');

module.exports = {
  entry: path.join(__dirname, 'src', 'index.js'),
  context: __dirname,
  output: {
    path: path.join(__dirname, 'dist'),
    filename: 'index.js',
    libraryTarget: 'commonjs2'
  },
  target: 'node',
  module: {
    loaders: [
      { test: /\.js$/, loader: 'babel-loader', exclude: /node_modules/ }
    ]
  },
  externals: [require('webpack-node-externals')()]
};
