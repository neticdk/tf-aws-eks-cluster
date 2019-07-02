# Netic AWS Terraform EKS Cluster

## Supported Terraform Versions

Terraform 0.12

## Usage

```hcl
module "vpc" {
  source = "github.com/neticdk/tf-aws-vpc"
  [...]
}

module "eks_workers" {
  source = "github.com/neticdk/tf-aws-eks-workers"
  [...]
}

module "eks_cluster" {
  source = "github.com/neticdk/tf-aws-eks-cluster"

  name            = var.eks_cluster_name
  cluster_version = var.eks_cluster_version
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  workers_security_group_ids   = [module.eks_workers.security_group_id]
  workers_security_group_count = 1

  cluster_admin_account_id = "123456789012"

  aws_role_name = "eks-global-cluster-admin"

  map_roles = [
    {
      role_arn = "arn:aws:iam::123456789012:role/sysadmin"
      username = "sysadmin"
      group    = "system:masters"
    },
    {
      role_arn = "arn:aws:iam::123456789012:role/cicd"
      username = "cicd"
    },
  ]
  map_roles_count = 2
}
```

<!---BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK--->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| allowed\_cidr\_blocks | List of CIDR blocks allowed to connect to the cluster | list | `<list>` | no |
| allowed\_security\_groups | List of additoinal security group ids allowed to connect to the cluster | list | `<list>` | no |
| allowed\_security\_groups\_count | Count of allowed security groups | string | `"0"` | no |
| aws\_profile\_name | AWS Profile Name to use when calling kubectl | string | `"futadmin"` | no |
| aws\_role\_name | AWS Role Name to use when calling kubectl | string | `"eks-global-cluster-admin"` | no |
| cluster\_admin\_account\_id | Account ID of account that needs to be trusted for assuming the cluster admin role | string | n/a | yes |
| cluster\_version | Cluster Version | string | `""` | no |
| global\_cluster\_admin\_group | Name of IAM group that will be allowed to assume the global cluster admin role | string | `"EKSGlobalClusterAdmins"` | no |
| global\_cluster\_admin\_role | Name of IAM role that will be added to the system:masters group | string | `"eks-global-cluster-admin"` | no |
| map\_roles | Additional IAM roles to add to the aws-auth configmap. See examples/eks_test_fixture/variables.tf for example format. | list | `<list>` | no |
| map\_roles\_count | The count of roles in the map_roles list. | string | `"0"` | no |
| name | EKS Cluster Name | string | n/a | yes |
| subnets | List of subnets to launch the cluster in | list(string) | n/a | yes |
| tags | A map of tags to add to all resources | map | `<map>` | no |
| vpc\_id | VPC ID | string | n/a | yes |
| workers\_security\_group\_count | Number of security group ids | string | n/a | yes |
| workers\_security\_group\_ids | List of worker security group ids allowed to connect to the cluster | list(string) | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| cluster\_admin\_arn | ARN of the EKS cluster admin role |
| eks\_cluster\_arn | The Amazon Resource Name (ARN) of the cluster |
| eks\_cluster\_certificate\_authority\_data | The base64 encoded certificate data required to communicate with the cluster |
| eks\_cluster\_endpoint | The endpoint for the Kubernetes API server |
| eks\_cluster\_id | The name of the cluster |
| eks\_cluster\_version | The Kubernetes server version of the cluster |
| iam\_role\_name\_workers | IAM role name for EKS worker groups |
| instance\_profile\_name | Name of the instance profile created for the worker nodes |
| kubeconfig | `kubeconfig` configuration to connect to the cluster using `kubectl`. |
| kubeconfig\_path | Where kubeconfig exists |
| security\_group\_id |  |

<!---END OF PRE-COMMIT-TERRAFORM DOCS HOOK--->

# Copyright
Copyright (c) 2019 Netic A/S. All rights reserved.

# License
MIT Licened. See LICENSE for full details.

