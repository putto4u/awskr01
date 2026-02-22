# 0. 배포 타겟 리전 변수
variable "region" {
  description = "인프라가 배포될 AWS 리전"
  type        = string
  default     = "ap-northeast-2"
}





# 1. 온프레미스 IDC 예약 대역 (모든 하이브리드 설계의 기준점)
variable "onprem_cidr" {
  description = "기존에 사용 중인 온프레미스 IDC 네트워크 대역"
  type        = string
  default     = "10.10.0.0/16"
}

# 2. VPC 전체 대역 설정 (한국 10.20, 미국 10.30, 유럽 10.40 계획 반영)
variable "vpc_cidr" {
  description = "AWS VPC의 전체 IP 대역 (리전별로 10단위씩 구분)"
  type        = string
  default     = "10.20.0.0/16"
}

# 3. NAT Gateway 생성 여부 (단독 구축 시 true, 향후 허브 연결 시 false로 변경)
variable "enable_nat" {
  description = "프라이빗 서브넷의 인터넷 통신을 위한 NAT Gateway 활성화 여부"
  type        = bool
  default     = true
}

# 4. 퍼블릭 서브넷 대역 (외부 노출이 필요한 자원 위치)
variable "public_subnets" {
  description = "퍼블릭 서브넷 대역 리스트 (AZ A와 C에 각각 배치)"
  type        = list(string)
  default     = ["10.20.1.0/24", "10.20.2.0/24"]
}

# 5. 프라이빗 서브넷 대역 (EKS 워커 노드 및 애플리케이션 위치)
variable "private_subnets" {
  description = "EKS 전용 프라이빗 서브넷 대역 리스트 (AZ A와 C에 각각 배치)"
  type        = list(string)
  default     = ["10.20.10.0/24", "10.20.11.0/24"]
}

# 6. 데이터베이스 서브넷 대역 (RDS 위치 및 온프레미스 복제 대역)
variable "database_subnets" {
  description = "RDS 전용 프라이빗 서브넷 대역 리스트 (온프레미스 충돌 방지를 위해 100번대 할당)"
  type        = list(string)
  default     = ["10.20.100.0/24", "10.20.101.0/24"]
}

