🚀 Terraform AWS EC2 Instance (RHEL 9) Deployment

This Terraform project provisions a Red Hat Enterprise Linux (RHEL 9) EC2 instance in the Mumbai (ap-south-1) AWS region. It uses the latest available RHEL 9 AMI, places the instance in a specific subnet, and allows basic SSH and HTTP access via a security group.

✅ Features

Deploys an EC2 instance running RHEL 9

Fetches the latest AMI from official RHEL owner ID

Configures networking in ap-south-1a

Attaches a security group allowing SSH (22) and HTTP (80)

Creates gp3 10GB root volume

Automatically assigns a public IP

Uses key pair named k8s for SSH access

🌐 Prerequisites

AWS account with IAM permissions

Terraform CLI installed

An existing VPC and subnet in ap-south-1a

AWS credentials configured (~/.aws/credentials or environment variables)

An existing key pair named k8s in your AWS EC2 dashboard

🛠️ Usage

    Clone the repo

git clone https://github.com/yuvrajsi9gh/Terraform-AWS.git cd Terraform-AWS

    Initialize Terraform

terraform init

    Plan the deployment

terraform plan

    Apply the configuration

terraform apply

Type yes to confirm.

📌 Notes

Update the vpc-id and availability-zone in main.tf if you are using a different VPC or AZ.

The security group allows open access on port 22 (SSH) and port 80 (HTTP). You can restrict this for security.

Terraform state files are not pushed to GitHub. Ensure .gitignore contains:

.terraform/
*.tfstate
*.tfstate.*
*.pem

🧹 Destroy Resources

To remove all created infrastructure:

terraform destroy

📧 Contact

For any questions, feel free to reach out: GitHub: yuvrajsi9gh@gmail.com
