module "dev_cluster" {
  source        = "./cluster"
  cluster_name  = "dev"
  instance_type = "t2.micro"
  node_grp_desired_size = "1"
}

/* module "prod_cluster" {
  source        = "./cluster"
  cluster_name  = "prod"
  instance_type = "m5.large"
  node_grp_desired_size = "2"
} */