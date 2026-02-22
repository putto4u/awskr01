# 0. AWS 프로바이더 설정: 전달받은 region 변수를 사용하여 배포 위치를 확정합니다.
provider "aws" {
  region = var.region
}



# AWS 공식 VPC 모듈을 호출하여 AWS의 권장 표준에 맞춘 네트워크 망을 생성합니다.
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "awskr01-spoke-vpc"
  cidr = var.vpc_cidr

  # 한국 리전(ap-northeast-2)의 A와 C 가용 영역을 사용하여 물리적인 서버 장애에 대비(고가용성 확보)합니다.
  azs              = ["ap-northeast-2a", "ap-northeast-2c"]
  public_subnets   = var.public_subnets
  private_subnets  = var.private_subnets
  database_subnets = var.database_subnets

  # 데이터베이스 서브넷 그룹 자동 생성 옵션
  # AWS RDS를 다중 가용 영역(Multi-AZ)으로 배포하려면 반드시 서브넷 그룹이 필요합니다.
  create_database_subnet_group = true

  # NAT Gateway 생성 설정
  # 프라이빗 서브넷 안의 서버들이 외부에서 보안 패치 등을 다운로드하기 위해 필요합니다.
  # [과금 주의] NAT Gateway는 생성된 시간당 약 $0.045의 고정 비용이 발생합니다.
  enable_nat_gateway = var.enable_nat
  
  # 비용 절감을 위해 각 가용 영역마다 만들지 않고, 1개의 NAT Gateway만 생성하여 공유합니다.
  single_nat_gateway = true 

  tags = {
    Project     = "awskr01"
    Terraform   = "true"
    Environment = "spoke"
  }
}

# 온프레미스(10.10.x.x)와 AWS 데이터베이스 간의 마이그레이션(데이터 이관) 및 양방향 복제를 위한 방화벽 규칙입니다.
# 실무에서는 인프라를 한 번 생성하면 수정이 까다로우므로, 이처럼 향후 확장될 연결성(Connectivity)을 미리 코드로 열어두는 것이 좋습니다.
resource "aws_security_group" "db_migration_security_group" {
  name        = "awskr01-db-migration-sg"
  description = "Allow Database replication traffic from On-premises IDC"
  
  # 위에서 만든 VPC 내부에 이 보안 그룹을 위치시킵니다.
  vpc_id      = module.vpc.vpc_id

  # 인바운드(Ingress): 외부에서 AWS 안으로 들어오는 트래픽 통제 규칙
  ingress {
    from_port   = 3306 # MySQL/MariaDB 데이터베이스의 기본 통신 포트
    to_port     = 3306
    protocol    = "tcp"
    
    # 인터넷 전체(0.0.0.0/0)가 아닌, 오직 사내 전산실(온프레미스 10.10 대역)에서만 DB 접근을 허용합니다.
    cidr_blocks = [var.onprem_cidr]
    description = "Allow database replication traffic from On-prem"
  }

  # 아웃바운드(Egress): AWS 안에서 외부로 나가는 트래픽 규칙
  # 데이터베이스가 외부에 응답을 주어야 하므로 나가는 길은 모두 열어둡니다.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # 모든 프로토콜 허용
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "awskr01-db-migration-sg"
  }
}

