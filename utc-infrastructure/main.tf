module "vpc" {
    source = "./modules/vpc"
    project = var.project
    env     = var.env
    vpc_cidr = "10.10.0.0/16"
    azs = ["us-east-1a", "us-east-1b", "us-east-1c"]
    single_nate_gateway = var.env == "dev" ? true : false # Use single NAT Gateway for dev environment to save costs    
  
}

module "security_groups" {
    source = "./modules/security_groups"
    project = var.project
    env     = var.env
    vpc_id = module.vpc.vpc_id
    my_ip = var.my_ip
}

module "ec2" {
    source = "./modules/ec2"
    project = var.project
    env     = var.env
    vpc_id = module.vpc.vpc_id
    public_subnet_id = module.vpc.public_subnet_id
    private_subnet_id = module.vpc.private_subnet_id
    bastion_sg_id = module.security_groups.bastion_sg_id
    app_sg_id = module.security_groups.app_sg_id
    instance_type = "t2.micro"
    ami_id = var.ami_id
    key_name = module.ec2.key_name
    instance_profile_name = module.iam.instance_profile_name
    efs_dns_name = module.efs.efs_dns_name
}

module "alb" {
    source = "./modules/alb"
    project = var.project
    env     = var.env
    vpc_id = module.vpc.vpc_id
    public_subnet_ids = module.vpc.public_subnet_id
    alb_sg_id = module.security_groups.alb_sg_id
    app_server_id = module.ec2.app_server_ids
}

module "rds" {
    source = "./modules/rds"
    project = var.project
    env     = var.env
    vpc_id = module.vpc.vpc_id
    db_instance_class = "db.t3.micro"
    db_username = var.db_username
    db_password = var.db_password
    private_subnet_ids = module.vpc.private_subnet_id
    db_sg_id = module.security_groups.db_sg_id
    multi_az           = var.env == "dev" ? false : true
  skip_final_snapshot = var.env == "dev" ? true : false
}

module "s3" {
  source  = "./modules/s3"
  project = var.project
  env     = var.env
}

module "iam" {
  source        = "./modules/iam"
  project       = var.project
  env           = var.env
  s3_bucket_arn = module.s3.bucket_arn
}

module "efs" {
    source = "./modules/efs"
    project = var.project
    env     = var.env
    vpc_id = module.vpc.vpc_id
    private_subnet_ids = module.vpc.private_subnet_id
    app_sg_id = module.security_groups.app_sg_id
    azs = ["us-east-1a", "us-east-1b", "us-east-1c"]
  
}
module "sns" {
    source  = "./modules/sns"
    project = var.project
    env     = var.env
    email   = var.email
  
}
module "asg" {
    source = "./modules/asg"
    project = var.project
    env     = var.env
    ami_id = var.asg_ami_id
    instance_type = "t2.micro"
    app_sg_id = module.security_groups.app_sg_id
    key_name = module.ec2.key_name
    instance_profile_name = module.iam.instance_profile_name
    private_subnet_ids = module.vpc.private_subnet_id
    target_group_arn = module.alb.target_group_arn
    efs_dns_name = module.efs.efs_dns_name
    sns_topic_arn = module.sns.topic_arn
    min_size = 2
    max_size = 6 
    scale_out_cpu = 80
  
}
module "eks" {
    source = "./modules/eks"
    cluster_name = "${var.env}-utc-eks-cluster"
    cluster_version = "1.32"
    private_subnet_ids = module.vpc.private_subnet_id
    public_subnet_ids = module.vpc.public_subnet_id
    vpc_id = module.vpc.vpc_id

    node_group_instance_type = "t3.medium"
    node_group_min_size = 1
    node_group_max_size = 5
    node_group_desired_size = 2
    env = var.env
  
}