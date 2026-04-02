# AWS 3-Tier Architecture: Scalable Java Deployment

This project was my deep dive into building a production-ready environment on AWS. Instead of just running an app on a single server, I focused on isolation, security, and automation. I deployed a **Java Spring Boot (PetClinic)** application across multiple subnets, backed by a managed **RDS MySQL** database.

The core goal was to implement a **"Golden AMI"** strategy—baking the environment once and letting the infrastructure scale itself.

---

## Architecture Overview
I followed AWS best practices by separating the stack into three distinct layers:

* **Public Tier:** An **Application Load Balancer (ALB)** as the single entry point. I used a NAT Gateway so my private instances could still reach the internet for security patches without being exposed to the web.
* **Application Tier:** A fleet of Ubuntu EC2 instances managed by an **Auto Scaling Group (ASG)**. These live in private subnets and handle all the logic.
* **Data Tier:** A managed **Amazon RDS (MySQL)** instance, completely isolated in its own private data subnets.

---

##  The Stack
* **Cloud:** AWS (VPC, EC2, RDS, ALB, ASG, IAM)
* **Image Automation:** Packer (Baking the "Golden AMI")
* **Configuration:** Ansible (used within Packer for environment setup)
* **App/Build:** Java 17 + Maven
* **Database:** MySQL 8.0(AWS-RDS)
* **Scripting:** Bash (User Data) for environment injection

---

##  How I Built It

### 1. Automating the "Golden AMI"
I didn't want to manually install Java and Maven every time a new server launched. I used **Packer** to build a custom AMI. This ensures that every instance the Auto Scaling Group spins up is identical and ready to run the app in seconds.

### 2. Networking & Security First
I built a custom VPC with a split-subnet design. The EC2 instances and the RDS database have **no public IP addresses**. I configured the Security Groups so that the database *only* accepts traffic from the Application Tier, and the App Tier *only* accepts traffic from the Load Balancer.

### 3. Launch Templates & Dynamic Config
To get the Java app talking to the database, I used a **Launch Template** with a custom **User Data** script. This script handles the "last mile" configuration by injecting the RDS endpoint and credentials as environment variables directly into the application process on boot.

---

##  Real-World Challenges 
 Here are a few things I had to troubleshoot:

* **Security Group Dependencies:**  I realized you can't delete SGs that reference each other. I had to learn to break the "chain of trust" rules first before AWS would let me clean up.
* **The User Data Struggle:** Debugging Bash syntax inside an AWS User Data script is tricky. I had some trial and error getting `${DB_ENDPOINT}` to export correctly so the JAR file could pick it up during the systemd start.
* 
---

##  Future Roadmap: Moving to Terraform
While this deployment was a success using the AWS Console and Packer, the next phase is to eliminate manual configuration entirely. My goal is to transition this to a fully automated **Infrastructure as Code (IaC)** workflow.

* **VPC Automation:** Using Terraform to define the public/private subnets, Route Tables, and NAT Gateway dynamically.
* **Modular RDS:** Writing a reusable Terraform module for the MySQL instance.
* **Integrated Lifecycle:** Linking the Packer-generated AMI ID directly into a Terraform Launch Template for a single-command deployment.

---

## Final Results
After the ASG went live, the Load Balancer confirmed two **Healthy** targets. I was able to hit the ALB DNS, register new pets in the UI, and verify the records were persisting in the RDS instance. 

> **Note:** All resources were terminated after testing to stay within the AWS Free Tier limits.

---

