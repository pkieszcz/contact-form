resource "aws_s3_bucket" "contact-form" {
  bucket = "pkieszcz-contact-form"
  acl    = "public-read"

  policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "PublicReadForGetBucketObjects",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::pkieszcz-contact-form/*"
    }
  ]
}
EOF

  website {
    index_document = "index.html"
  }

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "POST"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_object" "index" {
  bucket       = "${aws_s3_bucket.contact-form.id}"
  key          = "index.html"
  content_type = "text/html"
  source       = "../src/static-site/index.html"
  etag         = "${md5(file("../src/static-site/index.html"))}"
}
