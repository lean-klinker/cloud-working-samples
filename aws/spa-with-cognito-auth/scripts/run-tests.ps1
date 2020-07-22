$CURRENT_DIRECTORY = Get-Location
$LAMBDA_DIRECTORY = [io.path]::Combine(${CURRENT_DIRECTORY}, "lambda")
$SPA_DIRECTORY = [io.path]::Combine(${CURRENT_DIRECTORY}, "spa")

function Execute-Node-Tests([string] $directory) {
    Push-Location $directory
        yarn install
        yarn test --ci
    Pop-Location
}

function Main() {
    Execute-Node-Tests -directory ${LAMBDA_DIRECTORY}
    Execute-Node-Tests -directory ${SPA_DIRECTORY}
}

Main