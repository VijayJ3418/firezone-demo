$env:GIT_EDITOR = "echo"
git add .
git commit -m "Fix Terraform state conflicts and resource import issues - Firezone Load Balancer deployment"
git push origin main --force