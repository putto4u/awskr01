remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    # 과금 주의: S3 버킷에 상태 파일이 저장되며, 저장된 용량 및 요청 횟수에 따라 소액의 종량제 요금이 발생합니다.
    bucket         = "awskr01-tfstate-apne2-0001" # 본인만의 고유한 이름으로 변경 필수
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    
    # 과금 주의: 동시성 제어를 위한 DynamoDB 테이블이 생성되며, 읽기/쓰기 용량에 따른 요금이 발생합니다.
    dynamodb_table = "global-microservices-tflock-table"
  }
}




# 모든 리소스에 공통으로 들어갈 글로벌 태그 정의
inputs = {
  default_tags = {
    Project     = "awskr01-Hub-Spoke"
    ManagedBy   = "Terragrunt"
  }
}

