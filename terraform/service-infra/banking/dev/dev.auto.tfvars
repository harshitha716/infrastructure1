# Generic Variables
project_id           = "development-351109"
project              = "zamp"
environment          = "dev"
region               = "asia-southeast1"
spanner_instance_name = "zamp-dev-sg-cloudspanner"

# cloudfunctions = [
#     {
#         name             = "zamp-tag-recommender-training"
#         description      = "test"
#         runtime          = "python310"
#         available_memory_mb = "256M" 
#         entry_point      = "train_model"
#         max_instance_request_concurrency = 1
#         object          = "zamp-dev-sg-cloudfunction_bucket/tag-recommender/training.zip"
#     },
#     {
#         name             = "zamp-tag-recommender-api"
#         description      = "test"
#         runtime          = "python310"
#         available_memory_mb = "256M" 
#         entry_point      = "get_recommendation"
#         max_instance_request_concurrency = 1
#         object          = "zamp-dev-sg-cloudfunction_bucket/tag-recommender/api.zip"

#     }
# ]