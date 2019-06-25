resource "aws_dynamodb_table" "contact-form" {
  name           = "contact-form"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "email"

  attribute {
    name = "email"
    type = "S"
  }

  tags {
    Name = "Contact-form"
  }
}
