variable "source_bucket_name" {
  type        = string
  description = "Name for source s3 bucket"
}

variable "enable_replication" {
  type        = bool
  description = "Whether to create the replication configuration on the source"
  default     = true
}

variable "storage_class" {
  type        = string
  description = "AWS S3 Storage Class to use for replicated data"
  default     = "GLACIER_IR"
}

locals {
  source_bucket_arn        = "arn:aws:s3:::${var.source_bucket_name}"
  dest_bucket_name         = "${var.source_bucket_name}-backup"
  dest_bucket_arn          = "arn:aws:s3:::${local.dest_bucket_name}"
  source_bucket_object_arn = "arn:aws:s3:::${var.source_bucket_name}/*"
  dest_bucket_object_arn   = "arn:aws:s3:::${local.dest_bucket_name}/*"
  source_root_user_arn     = "arn:aws:iam::${data.aws_caller_identity.source.account_id}:root"
}
