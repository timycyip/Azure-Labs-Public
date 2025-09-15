param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory=$true)]
    [string]$WebAppName,

    [Parameter(Mandatory=$true)]
    [string]$GitHubRepoUrl,

    [Parameter(Mandatory=$false)]
    [string]$Branch = "main",

    [Parameter(Mandatory=$false)]
    [bool]$ConfigureGitHubDeployment = $true
)

Write-Host "Deploying Web App '$WebAppName' from GitHub repo '$GitHubRepoUrl'..." -ForegroundColor Green

# Ensure Azure CLI is installed and logged in
try {
    az account show | Out-Null
    Write-Host "Azure CLI is authenticated." -ForegroundColor Green
} catch {
    Write-Error "Azure CLI is not installed or not logged in. Please install Azure CLI and run 'az login'."
    exit 1
}

# Check for required tools
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Error "Azure CLI is not installed. Please install Azure CLI from https://aka.ms/azure-cli"
    exit 1
}

Write-Host "Checking Web App deployment configuration..." -ForegroundColor Cyan

# Step 1: Verify Web App exists and get its details
try {
    $webAppInfo = az webapp show --name $WebAppName --resource-group $ResourceGroupName | ConvertFrom-Json
    if (-not $webAppInfo) {
        throw "Web App '$WebAppName' not found"
    }

    $webAppUrl = "https://$($webAppInfo.defaultHostName)"
    Write-Host "Web App found: $webAppUrl" -ForegroundColor Green
    Write-Host "SKU: $($webAppInfo.sku)" -ForegroundColor Yellow
} catch {
    Write-Error "Failed to get Web App details: $($_.Exception.Message)"
    exit 1
}

# Step 2: Configure GitHub Deployment (recommended approach)
if ($ConfigureGitHubDeployment) {
    Write-Host "Configuring GitHub source control deployment..." -ForegroundColor Cyan

    try {
        # Set up deployment source to GitHub with manual integration
        $gitCommandArgs = @(
            "webapp",
            "deployment",
            "source",
            "config",
            "--name", $WebAppName,
            "--resource-group", $ResourceGroupName,
            "--repo-url", $GitHubRepoUrl,
            "--branch", $Branch,
            "--manual-integration"
        )

        # Only add git-token if environment variable is set (for private repos)
        if ($env:GITHUB_TOKEN) {
            $gitCommandArgs += @("--git-token", $env:GITHUB_TOKEN)
        }

        & az $gitCommandArgs

        # Handle exit codes more specifically
        if ($LASTEXITCODE -eq 0) {
            Write-Host "GitHub deployment source configured successfully." -ForegroundColor Green
        } elseif ($LASTEXITCODE -eq 3) {
            # Exit code 3 typically means the command was cancelled or interrupted
            Write-Host "GitHub deployment configuration was cancelled." -ForegroundColor Yellow
            throw "GitHub deployment configuration was cancelled"
        } else {
            # Check if it's a token-related error
            $errorOutput = (& az webapp deployment source show --name $WebAppName --resource-group $ResourceGroupName 2>&1) -join "`n"
            if ($errorOutput -match "SourceControlToken.*not found") {
                throw "GitHub token authentication failed. For private repositories, please set the GITHUB_TOKEN environment variable."
            } else {
                throw "GitHub deployment configuration failed with exit code $LASTEXITCODE"
            }
        }
        Write-Host "Note: Manual integration selected for demo purposes." -ForegroundColor Yellow
        Write-Host "For automatic deployments, consider using GitHub Actions with manual-integration=false" -ForegroundColor Yellow

    } catch {
        Write-Host "GitHub deployment config failed, falling back to manual ZIP deployment..." -ForegroundColor Yellow
        $ConfigureGitHubDeployment = $false
    }
}

# Step 3: Manual ZIP Deployment (fallback or preferred method)
if (-not $ConfigureGitHubDeployment) {
    Write-Host "Using manual ZIP deployment method..." -ForegroundColor Cyan

    # Check for git (only needed for manual deployment)
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Error "Git is not installed. Please install Git from https://git-scm.com/downloads"
        exit 1
    }

    # Temporary directory for cloning - use a safe path in current directory
    $currentPath = Get-Location
    $tempDir = Join-Path $currentPath.Path ".webapp-deploy-temp"
    if (Test-Path $tempDir) {
        Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    New-Item -ItemType Directory -Path $tempDir -ErrorAction Stop | Out-Null
    Write-Host "Using temporary directory: $tempDir" -ForegroundColor Yellow

    try {
        Set-Location $tempDir

        # Clone GitHub Repository
        Write-Host "Cloning GitHub repository..." -ForegroundColor Cyan
        try {
            $repoUrlWithToken = $GitHubRepoUrl
            if ($env:GITHUB_TOKEN) {
                $repoUrlWithToken = $GitHubRepoUrl -replace "https://", "https://$env:GITHUB_TOKEN@"
            }

            git clone --branch $Branch --single-branch $repoUrlWithToken "repo-clone" | Out-Null
            if ($LASTEXITCODE -ne 0) {
                throw "Git clone failed"
            }

            Write-Host "Repository cloned successfully." -ForegroundColor Green
        } catch {
            Write-Error "Failed to clone repository: $($_.Exception.Message)"
            Write-Host "Note: For private repositories, set GITHUB_TOKEN environment variable" -ForegroundColor Yellow
            exit 1
        }

        # Create ZIP Archive
        Write-Host "Creating ZIP archive..." -ForegroundColor Cyan
        $zipFileName = "webapp-deployment.zip"
        try {
            $repoDir = Join-Path $tempDir "repo-clone"
            Compress-Archive -Path "$repoDir/*" -DestinationPath $zipFileName -Force -ErrorAction Stop
            Write-Host "ZIP archive created: $zipFileName" -ForegroundColor Green
        } catch {
            Write-Error "Failed to create ZIP archive: $($_.Exception.Message)"
            exit 1
        }

        # Deploy via ZIP Upload
        Write-Host "Deploying Web App via ZIP upload..." -ForegroundColor Cyan
        try {
            $zipPath = Join-Path $tempDir $zipFileName

            az webapp deployment source config-zip `
                --resource-group $ResourceGroupName `
                --name $WebAppName `
                --src $zipPath 2>&1

            if ($LASTEXITCODE -ne 0) {
                throw "ZIP deployment failed"
            }

            Write-Host "Web App deployed successfully via ZIP upload!" -ForegroundColor Green

        } catch {
            Write-Error "Failed to deploy Web App: $($_.Exception.Message)"
            Write-Host "Note: Ensure the Web App has Python runtime configured" -ForegroundColor Yellow
            exit 1
        }

    } finally {
        # Cleanup
        Write-Host "Cleaning up temporary files..." -ForegroundColor Cyan
        Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        Pop-Location
    }
}

# Step 4: Verify deployment and get Web App URL
Write-Host "Verifying deployment..." -ForegroundColor Cyan
try {
    $deploymentDetails = az webapp show --name $WebAppName --resource-group $ResourceGroupName --query "[{Status: state, URL: defaultHostName, SKU: sku, Location: location}]" -o jsonc | ConvertFrom-Json

    Write-Host "Deployment Status: $($deploymentDetails.Status)" -ForegroundColor Green
    Write-Host "Web App URL: https://$($deploymentDetails.URL)" -ForegroundColor Green
    Write-Host "SKU: $($deploymentDetails.SKU)" -ForegroundColor Yellow
    Write-Host "Location: $($deploymentDetails.Location)" -ForegroundColor Yellow

} catch {
    Write-Host "Could not retrieve deployment details (deployment may still be in progress)" -ForegroundColor Yellow
}

Write-Host "`nWeb App Deployment completed successfully!" -ForegroundColor Green
Write-Host "It may take a few minutes for the application to fully start." -ForegroundColor Yellow
Write-Host "Access your web app at: https://$($webAppInfo.defaultHostName)" -ForegroundColor Cyan

# Instructions for future deployments
Write-Host "`nFor future deployments:" -ForegroundColor Cyan
Write-Host "- If using GitHub deployment: Push changes to the configured branch" -ForegroundColor Cyan
Write-Host "- For manual deployments: Run this script again with updated repository" -ForegroundColor Cyan
Write-Host "- Check deployment status: az webapp deployment list --name $WebAppName --resource-group $ResourceGroupName" -ForegroundColor Cyan
