param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory=$true)]
    [string]$FunctionAppName,

    [Parameter(Mandatory=$true)]
    [string]$GitHubRepoUrl,

    [Parameter(Mandatory=$false)]
    [string]$Branch = "main"
)

Write-Host "Deploying Function App '$FunctionAppName' from GitHub repo '$GitHubRepoUrl' (branch: $Branch)..." -ForegroundColor Green

# Ensure Azure CLI is installed and logged in
try {
    az account show | Out-Null
    Write-Host "Azure CLI is authenticated." -ForegroundColor Green
} catch {
    Write-Error "Azure CLI is not installed or not logged in. Please install Azure CLI and run 'az login'."
    exit 1
}

# Set Git source control for the Function App
Write-Host "Configuring Git source control for Function App..." -ForegroundColor Cyan

try {
    # Use Azure CLI to set the Git repository
    $result = az functionapp deployment source config `
        --name $FunctionAppName `
        --resource-group $ResourceGroupName `
        --repo-url $GitHubRepoUrl `
        --branch $Branch `
        --git-token $env:GITHUB_TOKEN `
        --manual-integration

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Git source control configured successfully!" -ForegroundColor Green
        Write-Host "Deployment initiated. It may take a few minutes for changes to reflect." -ForegroundColor Yellow
    } else {
        Write-Error "Failed to configure Git source control"
        exit 1
    }
} catch {
    Write-Error "Deployment failed with error: $($_.Exception.Message)"
    Write-Host "Note: If you don't have a GITHUB_TOKEN set, you can either:" -ForegroundColor Yellow
    Write-Host "  1. Set GITHUB_TOKEN environment variable: `$env:GITHUB_TOKEN = 'your-token'" -ForegroundColor Yellow
    Write-Host "  2. Create a Personal Access Token in GitHub" -ForegroundColor Yellow
    Write-Host "  3. Or deploy manually using: func azure functionapp publish $FunctionAppName --python" -ForegroundColor Yellow
    exit 1
}

Write-Host "Deployment script completed successfully!" -ForegroundColor Green
