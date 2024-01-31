resource "aws_s3_bucket" "my_bucket" {
  bucket        = "astanalyzerterraformbucket"
  force_destroy = true

  tags = {
    Name = "astanalyzerterraformbucket"
  }
}
