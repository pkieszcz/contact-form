console.log('Loading function');
const AWS = require('aws-sdk');
const validate = require("validate.js");
const ddb = new AWS.DynamoDB.DocumentClient();

exports.handler = (event, context, callback) => {
  console.log('Received event:', JSON.stringify(event, null, 2));
  event = JSON.parse(event.body);
  var constraints = {
    email: {
      presence: true,
      email: true
    },
    name: {
      presence: true,
      length: {
        minimum: 1
      },
    },
    message: {
      presence: true,
      length: {
        minimum: 1
      },
    }
  };
  let invalid = validate(event, constraints);
  let params = {
    Item: {
      Timestamp: Date.now(),
      name: event.name,
      email: event.email,
      message: event.message
    },
    TableName: 'contact-form'
  }

  ddb.put(params, function (err, data) {
    if (err) {
      console.error("Unable to add item. Error JSON:", JSON.stringify(err, null, 2));
    } else {
      console.log("Added item:", JSON.stringify(data, null, 2));
    }
  });

  var response = {
    "isBase64Encoded": false,
    "headers": { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
    "body": "{\"result\": \"Success.\"}"
  };
  callback(null, response);
};
