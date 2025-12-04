#!/bin/bash 
# Update the package list and install NGINX 
sudo yum update -y 
sudo yum install nginx -y 

# Start and enable NGINX 
sudo systemctl start nginx 
sudo systemctl enable nginx 

# Fetch metadata token 
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600") 

# Fetch instance details using IMDSv2 
INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" "http://169.254.169.254/latest/meta-data/instance-id") 
AVAILABILITY_ZONE=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" "http://169.254.169.254/latest/meta-data/placement/availability-zone") 
PUBLIC_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" "http://169.254.169.254/latest/meta-data/public-ipv4") 

# Create a simple HTML page displaying instance details 
sudo bash -c "cat > /usr/share/nginx/html/index.html <<EOF 
<h1>Instance Details</h1> 
<p><b>Instance ID:</b> $INSTANCE_ID</p> 
<p><b>Availability Zone:</b> $AVAILABILITY_ZONE</p> 
<p><b>Public IP:</b> $PUBLIC_IP</p> 
EOF" 

# Restart NGINX to ensure changes are applied 
sudo systemctl restart nginx 