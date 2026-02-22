# 최상위 디렉토리의 terragrunt.hcl (S3 원격 상태 설정)을 상속받습니다.
include {
  path = find_in_parent_folders()
}

# 재사용할 사전 작업 모듈의 경로를 지정합니다.
terraform {
  source = "../../../modules/prepare"
}

# 모듈에 필요한 변수를 주입합니다.
inputs = {
  region      = "ap-northeast-2"
  environment = "awskr01-prepare"
}

