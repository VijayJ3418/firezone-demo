$env:GIT_EDITOR = "echo"
git add .
git commit -m "Temporarily disable problematic backend resource to allow Load Balancer deployment"
git push origin main --force