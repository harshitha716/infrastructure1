
Structure :

aws-base : Basic infra componets , vpc , eks , general iam roles , cloudfront...etc 
aws-modules : modules for all the terrafrom scripts 
    Sub folder : services (pantheon , windmill, application-platform), these will be service specific componets , like s3 bucket , oam roles for pantheon service .
aws-services: Differnt workspcaes for above service specifc provisioning as thsi should be isolated from infra 
k8s-aws : This should have all the helm charts for cluster components (windmill , cert-manger, eso, traefik) this workflow shuld be parametriesd to pick env specifc values files and and just  deploy the helm charts 