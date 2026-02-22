# 1. ECR (Elastic Container Registry) 생성
# 프론트엔드와 백엔드의 도커(Docker) 이미지를 저장할 중앙 보관소입니다.
# 과금 주의: ECR은 저장된 이미지의 용량(GB당 월 $0.10) 및 데이터 전송량에 따라 과금이 발생합니다.

resource "aws_ecr_repository" "backend_repo" {
  name                 = "awskr01-backend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true # 보안 취약점 자동 스캔
  }
}

resource "aws_ecr_repository" "frontend_repo" {
  name                 = "awskr01-frontend"
  image_tag_mutability = "MUTABLE"
}

# 2. EKS Cluster IAM Role
# 쿠버네티스 컨트롤 플레인(Control Plane)이 AWS 인프라(EC2, 로드밸런서 등)를 제어하기 위해 필요한 권한입니다.

resource "aws_iam_role" "eks_cluster_role" {
  name = "awskr01-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

