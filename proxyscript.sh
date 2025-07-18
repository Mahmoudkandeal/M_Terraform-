#!/bin/bash

sudo yum update -y
sudo yum install nginx -y
sudo systemctl enable nginx
sudo systemctl start nginx
BACKEND_IP=$1
sudo tee /etc/nginx/conf.d/reverse-proxy.conf > /dev/null <<EOF
server {
    listen 80;
    location / {
        proxy_pass http://$BACKEND_IP:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF
sleep 2
sudo systemctl reload nginx