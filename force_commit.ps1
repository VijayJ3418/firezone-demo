$env:GIT_EDITOR = "echo"
git add .
git commit -m "Fix Load Balancer state conflicts - restore original resource names"
git push origin main --force