variable "key_ring_name"{
    description = "key ring name"
}

variable "location"{
    description = "location of the key ring"
}

variable "crypto_key_name"{
    description = "crypto key name"
}

variable "kms_rotation_duration"{
    description = "kms_rotation_duration"
    default = "7776000s"
}

variable "iam_member"{
    description = "default service account member"
}
