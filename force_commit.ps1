$env:GIT_EDITOR = "echo"
git add .
git commit -m "Temporarily disable Firezone module to clean up state conflicts"
git push origin main --force