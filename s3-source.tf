# S3 source IAM and bucket

# S3 source IAM

data "aws_iam_policy_document" "source_replication_role" {
  count = var.enable_replication ? 1 : 0
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com", "batchoperations.s3.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "source_replication_policy" {
  count = var.enable_replication ? 1 : 0
  statement {
    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
    ]

    resources = [
      "${local.source_bucket_arn}",
    ]
  }

  statement {
    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
    ]

    resources = [
      "${local.source_bucket_object_arn}",
    ]
  }

  statement {
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ObjectOwnerOverrideToBucketOwner",
    ]

    resources = [
      "${local.dest_bucket_object_arn}",
    ]
  }

  statement {
    action = [
      "s3:InitiateReplication"
    ]
    resource = [
      "${local.source_bucket_arn}",
    ]
  }

  statement {
    action = [
      "s3:GetReplicationConfiguration",
      "s3:PutInventoryConfiguration"
    ]

    resource = [
      "${local.source_bucket_arn}",
    ]
  }

  statement {
    action = [
      "s3:GetObject",
      "s3:GetObjectVersion"
    ]

    resource = [
      "${local.source_bucket_object_arn}",
    ]
  }

  statement {
    action = [
      "s3:PutObject"
    ]

    resource = [
      "${local.source_bucket_object_arn}",
    ]
  }
}

resource "aws_iam_role" "source_replication" {
  count              = var.enable_replication ? 1 : 0
  provider           = aws.source
  name               = "${var.source_bucket_name}-replication-role"
  assume_role_policy = data.aws_iam_policy_document.source_replication_role[0].json
}

resource "aws_iam_policy" "source_replication" {
  count    = var.enable_replication ? 1 : 0
  provider = aws.source
  name     = "${var.source_bucket_name}-replication-policy"
  policy   = data.aws_iam_policy_document.source_replication_policy[0].json
}

resource "aws_iam_role_policy_attachment" "source_replication" {
  count      = var.enable_replication ? 1 : 0
  provider   = aws.source
  role       = aws_iam_role.source_replication[0].name
  policy_arn = aws_iam_policy.source_replication[0].arn
}

# S3 source bucket

data "aws_s3_bucket" "source" {
  count    = var.enable_replication ? 1 : 0
  provider = aws.source
  bucket   = var.source_bucket_name
}

resource "aws_s3_bucket_replication_configuration" "replication" {
  count    = var.enable_replication ? 1 : 0
  provider = aws.source
  role     = aws_iam_role.source_replication[0].arn
  bucket   = data.aws_s3_bucket.source[0].id
  rule {
    id       = var.source_bucket_name
    status   = "Enabled"
    priority = 0
    destination {
      bucket        = aws_s3_bucket.dest.arn
      storage_class = var.storage_class
      access_control_translation {
        owner = "Destination"
      }
      account = data.aws_caller_identity.dest.account_id
    }
  }
}
