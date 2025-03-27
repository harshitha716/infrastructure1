# Generic Variables
project_id           = "staging-351109"
project              = "zamp"
environment          = "stg"
region               = "asia-southeast1"
spanner_instance_name = "zamp-stg-sg-cloudspanner"

# cloudfunctions = [
#     {
#         name             = "zamp-tag-recommender-training"
#         description      = "test"
#         runtime          = "python310"
#         available_memory_mb = "256" 
#         entry_point      = "train_data"
#     },
#     {
#         name             = "zamp-tag-recommender-api"
#         description      = "test"
#         runtime          = "python310"
#         available_memory_mb = "256" 
#         entry_point      = "get_recommendation"

#     }
# ]