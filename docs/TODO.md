## Roadmap
- add Docker container to docker hub + repo dockerfile
  <!-- - add docker hub (dh) -->
  <!-- - add docker to github wf -->
  - setup (Cleanup old Docker Hub tags) in gh wf
  - add dh to readme
  - add docs to dockerhub
  
- Add configuration command (read alias and add extra)
    1. show creads - for curent profile
    2. configure - change all configs + creds
    3. Add Upgrade app
    4. login ecr https://github.com/lamhaison/aws-cli-utils/blob/main/services/ecr.sh
    5. docs
   
- Add documentation

- Add Windows support
  
- Session caching (Not apply mfa each time)

- Auto-refresh role (same as aws-vault)

- Pipe-friendly output

- TUI mode

- JSON output mode
  `awscli-addons whoami --json`

- SSO support




docker build -t awscli-addons .

# Example: Check whoami (mounting your local AWS credentials)
docker run --rm -v ~/.aws:/root/.aws awscli-addons whoami
docker run --rm  -it awscli-addons bash
VERSION=feature/init tools/installer.sh