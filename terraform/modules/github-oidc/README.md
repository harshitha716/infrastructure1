## Example Github actions file

``` yml
name: Test Action

on: 
  workflow_dispatch:
  push:
    branches:
    - main

jobs:
  pull-request:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    steps:
    - name: Checkout
      uses: actions/checkout@v2

    - id: 'auth'
      name: 'Authenticate to GCP'
      uses: 'google-github-actions/auth@v0.5.0'
      with:
          create_credentials_file: 'true'
          workload_identity_provider: 'projects/<project-no>/locations/global/workloadIdentityPools/github-oidc-pool/providers/github-provider' ### workload identity provider
          service_account: 'github-actions-sa@project-id.iam.gserviceaccount.com' ### Service account crated
          token_format: "access_token"
    - id: 'gcloud'
      name: 'gcloud'
      run: |-
        gcloud auth login --brief --cred-file="${{ steps.auth.outputs.credentials_file_path }}"
        gcloud storage ls
```