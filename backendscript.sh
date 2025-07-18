#!/bin/bash
set -e
sudo yum update -y
sudo yum install -y python3 python3-pip git
# Install Python dependencies globally
sudo pip3 install flask flask_sqlalchemy
# Navigate to app directory
cd /home/ec2-user/cuteblog-flask
# Create systemd unit file for the Flask app
sudo tee /etc/systemd/system/flaskapp.service > /dev/null <<EOF
[Unit]
Description=Flask Blog App
After=network.target

[Service]
User=root
WorkingDirectory=/home/ec2-user/cuteblog-flask
ExecStart=/usr/bin/python3 app.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable flaskapp
sudo systemctl start flaskapp
