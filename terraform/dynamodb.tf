resource "aws_dynamodb_table" "contact-form" {
  name           = "contact-form"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "Timestamp"

  attribute {
    name = "Timestamp"
    type = "N"
  }

  tags {
    Name = "Contact-form"
  }

  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
}
