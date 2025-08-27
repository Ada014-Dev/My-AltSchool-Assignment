# My-AltSchool-Assignment
# CloudLaunch – AltSchool Cloud Engineering Semester 3, Month 1 Assessment

This project implements CloudLaunch, a lightweight product deployed on AWS.  
The tasks cover S3 (static site hosting + IAM policies) and VPC design.

---

Task 1: Static Website Hosting (S3 + IAM)

S3 Buckets
- **cloudlaunch-site-bucket**  
  - Hosts a simple static website (HTML/CSS/JS).  
  - Static website hosting enabled.  
  - Public read-only access for anonymous users.  
  - (Optional) Distributed via CloudFront for HTTPS and caching.  

- **cloudlaunch-private-bucket**  
  - Private storage bucket.  
  - Only `cloudlaunch-user` can `GetObject` and `PutObject`.  
  - No `DeleteObject` permission.  

- **cloudlaunch-visible-only-bucket**  
  - Private bucket.  
  - `cloudlaunch-user` can only **list the bucket** but cannot access its contents.  

IAM User: `cloudlaunch-user`
- Limited to only the three buckets above.  
- Permissions summary:  
  - `ListBucket` on all three buckets.  
  - `GetObject` on `cloudlaunch-site-bucket`.  
  - `GetObject` + `PutObject` on `cloudlaunch-private-bucket`.  
  - No access to objects in `cloudlaunch-visible-only-bucket`.  
  - No `DeleteObject` permission anywhere.  

**S3 Static Website**: [Static Website Url](http://cloudlaunch-site-bucket-adadev-014.s3-website-us-east-1.amazonaws.com)
- **CloudFront URL**: [CloudFront url](https://dziwgqnymnmqb.cloudfront.net/?utm_campaign=as-npt105112517)

 Task 2: VPC Design

VPC & Subnets
- **VPC**: `cloudlaunch-vpc` – CIDR block: `10.0.0.0/16`  
- **Subnets**:  
  - Public Subnet: `10.0.1.0/24`  
  - Application Subnet: `10.0.2.0/24`  
  - Database Subnet: `10.0.3.0/28`  

Internet Gateway
- **cloudlaunch-igw** attached to the VPC.  

Route Tables
- **cloudlaunch-public-rt**  
  - Associated with public subnet.  
  - Default route `0.0.0.0/0` → `cloudlaunch-igw`.  

- **cloudlaunch-app-rt**  
  - Associated with app subnet.  
  - No internet route (fully private).  

- **cloudlaunch-db-rt**  
  - Associated with DB subnet.  
  - No internet route (fully private).  

Security Groups
- **cloudlaunch-app-sg**  
  - Inbound: HTTP (port 80) allowed **within the VPC (10.0.0.0/16)**.  
  - Outbound: all allowed (default).  

- **cloudlaunch-db-sg**  
  - Inbound: MySQL (port 3306) allowed **only from cloudlaunch-app-sg**.  
  - Outbound: all allowed (default).  

IAM Permissions for VPC
- `cloudlaunch-user` has **read-only access** to:  
  - VPCs, Subnets, Route Tables, Internet Gateways, and Security Groups.  

---

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "S3Permissions",
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::cloudlaunch-site-bucket",
        "arn:aws:s3:::cloudlaunch-private-bucket",
        "arn:aws:s3:::cloudlaunch-visible-only-bucket"
      ]
    },
    {
      "Sid": "SiteBucketAccess",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": "arn:aws:s3:::cloudlaunch-site-bucket/*"
    },
    {
      "Sid": "PrivateBucketAccess",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::cloudlaunch-private-bucket/*"
    },
    {
      "Sid": "VPCReadOnly",
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeVpcs",
        "ec2:DescribeSubnets",
        "ec2:DescribeRouteTables",
        "ec2:DescribeInternetGateways",
        "ec2:DescribeSecurityGroups"
      ],
      "Resource": "*"
    }
  ]
}
