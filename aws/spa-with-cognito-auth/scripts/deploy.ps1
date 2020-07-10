param ([string] $environment = "dev")

function Create-Terraform-Backend-Bucket([string] $env) {
    $bucket_name = "spa-cognito-sample-${env}"
    aws s3 mb "s3://${bucket_name}"
}

function Build-Spa-Application() {
    yarn build
}

function Deploy-Terraform-Infrastructure([string] $env) {
    $plan_path = "plan.tfplan"

    Push-Location "./infrastructure/${env}"
        terraform init
        terraform plan -out $plan_path
    Pop-Location
}

function Teardown-Terraform-Infrastructure([string] $env) {
    Push-Location "./infrastructure/${env}"
        terraform destroy
    Pop-Location
}

function Main($env) {
    Build-Spa-Application
    Create-Terraform-Backend-Bucket($env)
    Deploy-Terraform-Infrastructure($env)
    Teardown-Terraform-Infrastructure($env)
}

Main($environment)