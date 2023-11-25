provider aws {
  region = var.region
  access_key = var.akey
  secret_key = var.skey
}

module "mvpc" {
   source = "./modules/vpc"
   vpc-cidr = var.vpc-cidr
   mani = var.mani
   az = var.az
   sub-cidr1 = var.sub-cidr1
   key = var.key
   ami = var.ami
   insta = var.insta
   }


output "public_ip" {
  value = module.mvpc.ec2_details.public_ip
}



