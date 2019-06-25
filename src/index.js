let AWS = require('aws-sdk');
const ddb = new AWS.DynamoDB.DocumentClient();
const validate = require("validate.js");
exports.handler = function (event, context, callback) {
	//due to lambda proxy integration
	event = JSON.parse(event.body)
	//validating email and name
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

	if (!invalid) {
		let today = new Date().toLocaleDateString();
		ddb.put({
			TableName: 'contact_form',
			Item: {
				'name': event.name,
				'email': event.email,
				'message': event.message
			}
		}, function (err, data) {
			if (err) {
				callback({body: err}, null);
			} else {
				callback(null, {body: "Successfully Saved Entry!"});
			}
		});
	} else {
		callback({body: invalid}, null);
	}
}