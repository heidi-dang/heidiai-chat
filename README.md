To install nano start-heidichat.sh

~~~
#!/bin/bash

# --- 1. SET VARIABLES ---
GH_REPO="https://github.com/heidi-dang/heidiai-chat.git"
GEMINI_API_KEY=""
DUCKDNS_TOKEN=""
DUCKDNS_SUBDOMAIN="heidichat"

# --- 2. CONFIGURE FIREWALL ---
# Ensure port 443 (HTTPS) and 81 (NPM Admin) are open
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 81/tcp
sudo ufw reload

# --- 3. CREATE DOCKER COMPOSE WITH REVERSE PROXY ---
cd /opt/app
cat <<EOF > docker-compose.yaml
services:
  heidi-chat:
    build:
      context: .
      dockerfile: Dockerfile.vultr
    container_name: heidi-chat
    restart: always
    expose:
      - "8080"
    environment:
      - GOOGLE_API_KEY=${GEMINI_API_KEY}
      - ENABLE_GOOGLE_API=True
      - WEBUI_AUTH=True
      - NODE_OPTIONS=--max-old-space-size=4096
    volumes:
      - heidi-data:/app/backend/data

  nginx-proxy-manager:
    image: 'jc21/nginx-proxy-manager:latest'
    container_name: nginx-proxy-manager
    restart: always
    ports:
      - '80:80'
      - '81:81'
      - '443:443'
    volumes:
      - ./npm-data:/data
      - ./npm-letsencrypt:/etc/letsencrypt

  duckdns:
    image: lscr.io/linuxserver/duckdns:latest
    container_name: duckdns
    restart: always
    environment:
      - SUBDOMAINS=${DUCKDNS_SUBDOMAIN}
      - TOKEN=${DUCKDNS_TOKEN}

volumes:
  heidi-data:
EOF

# --- 4. START THE STACK ---
docker compose up -d --build

echo "-------------------------------------------------------"
echo "Secure Stack is starting!"
echo "1. Go to: http://your_server_ip:81"
echo "2. Default Login: admin@example.com / changeme"
echo "3. Add a 'Proxy Host' for $DUCKDNS_SUBDOMAIN.duckdns.org"
echo "   -> Forward IP: heidi-chat"
echo "   -> Forward Port: 8080"
echo "   -> SSL Tab: Request a new certificate"
echo "-------------------------------------------------------"
~~~

~~~
chmod +x start_heidichat.sh
~~~
~~~
sudo ./start_heidichat.sh
~~~

Steps to Activate HTTPS:
Once the script finishes, you need to configure the certificate in the UI:

 Open http://ipaddress:81 in your browser.

Add Proxy Host:
~~~
Domain Names: heidichat.duckdns.org

Scheme: http

Forward Hostname/IP: heidi-chat (Docker DNS handles this automatically)

Forward Port: 8080

Enable: "Websockets Support" (Important for AI chat).

Get SSL:
~~~
Click the SSL tab.
~~~
Select Request a new SSL Certificate.

Enable Force SSL and HTTP/2 Support.
~~~

Agree to the Terms and click Save.