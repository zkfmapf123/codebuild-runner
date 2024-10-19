# CodeBuild Runner

## Tech / Todo...

- CodeBuild + Github Action
- Codeguru Reviewer
- Configuration Server Repository / Build Repository 
- Make Terraform

## 1. ECS + ALB 생성

- VPC는 이미 만들었음

```sh

    cd infra
    terraform init && terraform apply --auto-approve

    ## svc.leedonggyu.com 으로 통신
```

## 2. Codebuild + Runner 구성

### 만들기 전 전제조건...

- Codebuild는 Private Subnet에 위치 함 (NAT 존재해야 함)

### IAM 생성

```sh
## 해당 코드 참조
infra/codebuild.iam.tf
```


## ...

- CodeGuru는 아직 ap-northeast-2 리전에 출시안함...