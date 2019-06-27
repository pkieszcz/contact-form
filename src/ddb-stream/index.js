'use strict';
var AWS = require("aws-sdk");
var sns = new AWS.SNS();
const sns_topic_arn = process.env.SNS_TOPIC_ARN

exports.handler = (event, context, callback) => {

  event.Records.forEach((record) => {
    console.log('Stream record: ', JSON.stringify(record, null, 2));

    if (record.eventName == 'INSERT') {
      var who = JSON.stringify(record.dynamodb.NewImage.name.S);
      var when = JSON.stringify(record.dynamodb.NewImage.Timestamp.N);
      var what = JSON.stringify(record.dynamodb.NewImage.message.S);
      var email = JSON.stringify(record.dynamodb.NewImage.email.S);
      var params = {
        Subject: 'A new item from ' + who + ' ' + email,
        Message: 'User ' + who + ' inserted at ' + when + ':\n\n ' + what,
        TopicArn: sns_topic_arn
      };
      sns.publish(params, function (err, data) {
        if (err) {
          console.error("Unable to send message. Error JSON:", JSON.stringify(err, null, 2));
        } else {
          console.log("Results from sending message: ", JSON.stringify(data, null, 2));
        }
      });
    }
  });
  callback(null, `Successfully processed ${event.Records.length} records.`);
};
