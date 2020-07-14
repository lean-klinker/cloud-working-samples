param ([string] $environment = "dev", [bool] $should_destroy = $false)

$infrastructure_directory = "./infrastructure/${environment}"

function Ensure-Success([string] $message = "FAILURE") {
    $last_exit_code = $LASTEXITCODE
    if ($last_exit_code -ne 1) {
        Write-Host "${message}\r\nLast Exit Code: ${last_exit_code}"
        exit 1
    }
}

function Create-Terraform-Backend-Bucket() {
    $bucket_name = "spa-cognito-sample-${environment}"
    aws s3 mb "s3://${bucket_name}"
}

function Build-Spa-Application() {
    yarn build
    Ensure-Success -message "Spa build failed"
}

function Deploy-Terraform-Infrastructure() {
    $plan_path = "plan.tfplan"
    Push-Location "${infrastructure_directory}"
        terraform init
        Ensure-Success -message "Terraform init failed"

        terraform plan -out="${plan_path}" -input=false
        Ensure-Success -message "Terraform plan failed"

        terraform apply "${plan_path}"
        Ensure-Success -message "Terraform apply failed"
    Pop-Location
}

function Invalidate-Cloud-Front-Caches() {
    Push-Location "${infrastructure_directory}"
        $cloudfront_distribution_id = $(terraform output spa_cloud_front_distribution_id)
        Ensure-Success -message "Failed to get cloud formation distribution id from output"

        aws cloudfront create-invalidation --distribution-id "${cloudfront_distribution_id}" --paths '/settings.json'
        Ensure-Success -message "Failed to invalidate settings.json in cloudfront"

        aws cloudfront create-invalidation --distribution-id "${cloudfront_distribution_id}" --paths '/index.html'
        Ensure-Success -message "Failed to invalidate index.html in cloudfront"
    Pop-Location
}

function Destroy-Terraform-Infrastructure() {
    Push-Location "${infrastructure_directory}"
        terraform destroy
    Pop-Location
}

function Main() {
    Build-Spa-Application
    Create-Terraform-Backend-Bucket
    Deploy-Terraform-Infrastructure
    Invalidate-Cloud-Front-Caches

    if ($should_destroy -eq $True)
    {
        Destroy-Terraform-Infrastructure
    }
}

Main