# 최상위 폴더에 있는 전역 설정(상태 파일을 저장할 S3 백엔드 구성 등)을 자동으로 끌어와 상속받습니다.
include {
  path = find_in_parent_folders()
}

# 적용할 인프라 설계도(모듈)의 위치를 지정합니다.
terraform {
  source = "../../../../modules/aws-network-spoke"
}

# variables.tf에 정의된 변수들에 최종적으로 덮어씌울 실제 값들입니다.
inputs = {
  region           = "ap-northeast-2" # [추가] 한국 리전으로 명확히 주입
  onprem_cidr      = "10.10.0.0/16"
  vpc_cidr         = "10.20.0.0/16"
  enable_nat       = true
  public_subnets   = ["10.20.1.0/24", "10.20.2.0/24"]
  private_subnets  = ["10.20.10.0/24", "10.20.11.0/24"]
  database_subnets = ["10.20.100.0/24", "10.20.101.0/24"]
}

