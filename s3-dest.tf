# S3 destination bucket

data "aws_iam_policy_document" "dest_bucket_policy" {
  count = var.enable_destination ? 1 : 0
  statement {
    sid = "replicate-objects-from-${data.aws_caller_identity.source.account_id}"

    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ObjectOwnerOverrideToBucketOwner",
    ]

    resources = [
      "${local.dest_bucket_object_arn}",
    ]

    principals {
      type = "AWS"

      identifiers = [
        "${local.source_root_user_arn}",
      ]
    }
  }
}

resource "aws_s3_bucket" "dest" {
  count    = var.enable_destination ? 1 : 0
  provider = aws.dest
  bucket   = local.dest_bucket_name
  policy   = data.aws_iam_policy_document.dest_bucket_policy[0].json

  versioning {
    enabled = true
  }
}
