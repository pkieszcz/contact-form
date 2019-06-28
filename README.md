# Contact-form

This is a repository that contains basic contact-form that accepts json payload and saves entries as DynamoDB items. After each item that's inserted there is trigger for lambda that populates SNS topic.


# Architecture
This project uses AWS services like API Gateway, DynamoDB, Lambda and DynamoDB.

There are 2 lambda functions (contact-form & ddb-stream):
1. Validates input to be in correct format and then inserts into DynamoDB table
2. If DynamoDB event trigger lambda and item type is INSERTED then new item on SNS topic is populated.

The flow diagram for *contact-form* lambda
![](https://raw.githubusercontent.com/pkieszcz/contact-form/master/contact-form.png)

The flow diagram for *ddb-stream* lambda
![enter image description here](https://raw.githubusercontent.com/pkieszcz/contact-form/master/ddb-stream.png)

# Verification
1. In AWS console navigate to API Gateway Service
2. Go to APIs -> *contact-form* -> Resources
3. Click on POST and then on TEST
4. Put in request body
```
{
  "name": "pioter",
  "email": "pioter@example.com",
  "message": "seems to be working"
}
```
5. Click on test


# Intitial setup

1. Clone this repository
2. Install terraform 0.11.14 (follow terraform.io for instructions)
3. Ensure that you have a working AWS CLI profile
4. In root directory of this repository adjust variable *aws_profile* to correct AWS CLI profile in file *terraform/variables.tf*
5. In root level of directory execute ***terrafrom init***
6. In root level of directory execute ***terrafrom plan***
7. In root level of directory execute ***terrafrom apply***

#### Cleanup
1. In root diectory of this repo execute ***terraform destroy***
