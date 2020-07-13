param ([string] $environment = "dev", [bool] $should_destroy = $false)

function Create-Terraform-Backend-Bucket() {
    $bucket_name = "spa-cognito-sample-${environment}"
    aws s3 mb "s3://${bucket_name}"
}

function Build-Spa-Application() {
    yarn build
}

function Deploy-Terraform-Infrastructure() {
    $plan_path = "plan.tfplan"
    Push-Location "./infrastructure/${environment}"
        terraform init
        terraform plan -out="${plan_path}" -input=false
        terraform apply "${plan_path}"
    Pop-Location
}

function Destroy-Terraform-Infrastructure() {
    Push-Location "./infrastructure/${environment}"
        terraform destroy
    Pop-Location
}

function Main() {
    Build-Spa-Application
    Create-Terraform-Backend-Bucket
    Deploy-Terraform-Infrastructure

    if ($should_destroy -eq $True)
    {
        Destroy-Terraform-Infrastructure
    }
}

Main