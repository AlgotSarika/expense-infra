resource "aws_key_pair" "eks" {
  key_name   = "expense-eks"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCX+yziWWNOh8OCBh6deguL+CftzfdNrzHXk+GABgDNgqcvnHgM4IgH7FPNMX71AvzEBkkmIpfdAsN+VQBsphlL49U11I0t3ansF4Hx5nlHT16IKD+3KTtEJnzRVLDH6LtzhG1A8SQJY8aQ/33Gjhow/+6lTpxmU+Bj9cVHrDTXu/Q51chWU881+6YWo5qIZxDX3yFzFMiHaw7i386yJZI0nbjbHdjHAdS7aKshldgHQGaXNOX9YbKBeORqe4TH+YhfMdjPtRIbvoem4tRXO/uRwtPI6pcgPl2rGeUMR9td8a8cWgcAYcIbJ6oBhtSp7aC1aARiHM4PzD9VXVVQ7MssNxuMI2cJFzIaso0FwICPfexAfiVIV/S/gKAQ3S3y52m1S0J4aRzngN4PxRjf4n9L/3P0eRyJDGBEuIWtDPpguNDUqHaFlAsccLQ/ZC0/CViBplWWz9EQlsr9Phm/BjSSaTWhRONZP54WWDspzVGOMKOyU2H+wB5CPWFQK2PytbE= RTLenovo@DESKTOP-VNKI65R
"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.name
  cluster_version = "1.32" # later we upgrade 1.32
  create_node_security_group = false
  create_cluster_security_group = false
  cluster_security_group_id = local.eks_control_plane_sg_id
  node_security_group_id = local.eks_node_sg_id

  #bootstrap_self_managed_addons = false
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
    metrics-server = {}
  }

  # Optional
  cluster_endpoint_public_access = false

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  vpc_id                   = local.vpc_id
  subnet_ids               = local.private_subnet_ids
  control_plane_subnet_ids = local.private_subnet_ids

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    # blue = {
    #   # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
    #   #ami_type       = "AL2_x86_64"
    #   instance_types = ["m5.xlarge"]
    #   key_name = aws_key_pair.eks.key_name

    #   min_size     = 2
    #   max_size     = 10
    #   desired_size = 2
    #   iam_role_additional_policies = {
    #     AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    #     AmazonEFSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
    #     AmazonEKSLoadBalancingPolicy = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
    #   }
    # }

    green = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      #ami_type       = "AL2_x86_64"
      instance_types = ["m5.xlarge"]
      key_name = aws_key_pair.eks.key_name

      min_size     = 2
      max_size     = 10
      desired_size = 2
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        AmazonEFSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
        AmazonEKSLoadBalancingPolicy = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
      }
    }
  }

  

  tags = merge(
    var.common_tags,
    {
        Name = local.name
    }
  )
}