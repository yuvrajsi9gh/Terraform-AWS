# Terraform AWS: EC2 Instances with Application Load Balancer

This Terraform project sets up the following infrastructure on AWS in the **ap-south-1 (Mumbai)** region:

- **2 EC2 instances** (RHEL 9, `t2.micro`) in different subnets
- **Application Load Balancer (ALB)** - internet-facing
- **Listener on port 80**
- **Target Group** pointing to both EC2 instances
- **User Data** to install Apache HTTP Server and host a simple HTML message

---

## 🧾 Prerequisites

- AWS CLI configured with valid credentials (`aws configure`)
- Terraform installed (version 1.0 or later)
- A valid key pair named `k8s` in the specified region
- A VPC with at least two subnets (`ap-south-1a` and `ap-south-1b`)
- Subnet and VPC IDs updated in the `.tf` file

---

## ⚙️ How to Use

### 1. Initialize Terraform

```bash
terraform init
```

2. Validate the Configuration

```bash
terraform validate
```
3. Apply the Configuration

```bash
terraform apply
```

4. Confirm when prompted with yes.

🧹 To Destroy Resources

```bash
terraform destroy
```
🌐 Access the Web App

Once provisioned, the ALB DNS name (printed in Terraform output) can be used to access the two EC2 instances in a round-robin fashion. They each return:

Hello from instance 0
Hello from instance 1

🔒 Notes

    The project uses RHEL 9 AMI owned by 309956199498 (official Red Hat publisher on AWS).

    Security Group only opens port 80 to the internet.

    Load Balancer and EC2 instances are all tagged and managed using Terraform.

👨‍💻 Author

Yuvraj Singh
