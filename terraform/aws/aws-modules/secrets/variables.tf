variable "tags" {
  
}

variable "secrets" {
  description = "List of secrets to be created with descriptions"
  type        = list(object({
    name        = string
    description = string
    tags        = map(string)
  }))
}
