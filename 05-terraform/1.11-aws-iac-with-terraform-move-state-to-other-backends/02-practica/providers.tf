terraform {
  backend "s3" {
    bucket = "cmtr-iacp1ebx-backend-new-bucket-1791205963"
    key    = "tf_code.tfstate"
    region = "eu-west-1"
  }
}
