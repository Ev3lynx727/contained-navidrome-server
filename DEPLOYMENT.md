# Tailscale VPN Deployment Guide

This guide provides detailed instructions for deploying the Navidrome music server with Tailscale VPN integration using Docker containers.

## Overview

This setup uses a **container-based architecture** where:
- Tailscale runs in a dedicated container with network privileges
- Navidrome shares the Tailscale container's network stack
- All traffic flows through Tailscale's encrypted mesh network
- No host VPN installation required

## Prerequisites

### System Requirements
- Linux system with Docker and Docker Compose
- At least 1GB RAM, 2GB disk space
- Internet connection for container downloads

### Tailscale Account
- Sign up at [tailscale.com](https://tailscale.com)
- Create a tailnet (automatic with signup)
- Generate an auth key for unattended setup

## Quick Start

### 1. Clone and Prepare
```bash
git clone https://github.com/Ev3lynx727/contained-navidrome-server.git
cd contained-navidrome-server
```

### 2. Environment Setup
```bash
# Prepare Docker environment
./install-tailscale.sh

# This creates:
# - data/ directory for Navidrome data
# - music/ directory for music files
# - tailscale-state/ for Tailscale persistent state
```

### 3. Configure Authentication
```bash
# Edit .env file
nano .env

# Add your Tailscale auth key:
TS_AUTHKEY=tskey-auth-your-key-here
```

Get auth key from: https://login.tailscale.com/admin/settings/keys

### 4. Start Services
```bash
./start-tailscale-navidrome.sh
```

### 5. Verify Deployment
```bash
# Check status
./tailscale-monitor.sh status

# Get Tailscale IP
docker compose exec tailscale tailscale ip -4
```

## Detailed Setup Steps

### Step 1: System Preparation

The `install-tailscale.sh` script performs these actions:

1. **Docker Check**: Verifies Docker and Docker Compose are installed
2. **Directory Creation**:
   - `data/` - Navidrome database and configuration
   - `music/` - Your music library (mount your music here)
   - `tailscale-state/` - Tailscale daemon state (persistent)
3. **Environment Setup**: Creates `.env` from template if needed

### Step 2: Tailscale Configuration

#### Getting an Auth Key
1. Go to [Tailscale Admin Console](https://login.tailscale.com/admin/settings/keys)
2. Click "Generate auth key"
3. Configure options:
   - **Ephemeral**: No (we want persistent nodes)
   - **Pre-authorized**: Yes (auto-approve this device)
   - **Tags**: `tag:navidrome` (optional, for ACL control)
   - **Expiry**: Set as needed (or never)

#### Environment Variables
Edit `.env` with:
```bash
# Navidrome settings
ND_MUSICFOLDER=/music
ND_DATAFOLDER=/data
ND_PASSWORD=your_admin_password

# Tailscale auth key (required)
TS_AUTHKEY=tskey-auth-...
```

### Step 3: Music Library Setup

Place your music files in the `music/` directory:
```bash
# Example: Copy music from external drive
cp -r /mnt/external-drive/music/* ./music/

# Or create symbolic link
ln -s /path/to/your/music ./music
```

### Step 4: Service Startup

The `start-tailscale-navidrome.sh` script:

1. **Auth Check**: Verifies TS_AUTHKEY is configured
2. **Container Start**: Runs `docker compose up -d`
3. **Tailscale Connect**: Waits for Tailscale authentication (up to 60 seconds)
4. **Navidrome Ready**: Waits for Navidrome web interface (up to 60 seconds)
5. **Access Info**: Displays local and Tailscale IPs

### Step 5: Access and Testing

#### Local Access
- URL: `http://localhost:4533`
- Username: `admin`
- Password: As set in `ND_PASSWORD` (or empty if not set)

#### Remote Access (Tailscale)
- URL: `http://<tailscale-ip>:4533`
- Same credentials as local access
- Accessible from any device on your tailnet

#### Testing Commands
```bash
# Check all services
./tailscale-monitor.sh status

# Monitor continuously
./tailscale-monitor.sh monitor

# View logs
docker compose logs -f

# Test Navidrome API
curl -f http://localhost:4533/login
```

## Container Architecture Details

### Tailscale Container
```yaml
tailscale:
  image: tailscale/tailscale:latest
  environment:
    - TS_AUTHKEY=${TS_AUTHKEY}
    - TS_EXTRA_ARGS=--advertise-tags=tag:navidrome
  volumes:
    - ./tailscale-state:/var/lib/tailscale
  devices:
    - /dev/net/tun
  cap_add:
    - net_admin
    - net_raw
```

**Capabilities**:
- `net_admin`: Configure network interfaces
- `net_raw`: Raw socket access for ICMP
- Device access: `/dev/net/tun` for VPN tunnel

### Navidrome Container
```yaml
navidrome:
  image: deluan/navidrome:latest
  network_mode: service:tailscale  # Shares Tailscale network
  volumes:
    - ./data:/data
    - ./music:/music
```

**Networking**: Uses Tailscale container's network namespace, so all traffic goes through Tailscale.

## Tailscale ACL Configuration

For production, configure ACLs in the Tailscale admin console:

```json
{
  "acls": [
    {
      "action": "accept",
      "src": ["autogroup:member"],
      "dst": ["tag:navidrome:80,443,4533"]
    }
  ],
  "tagOwners": {
    "tag:navidrome": ["autogroup:admin"]
  }
}
```

## Systemd Service (Optional)

For automatic startup:

```bash
# Install service
sudo cp navidrome-tailscale.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable navidrome-tailscale

# Manual control
sudo systemctl start navidrome-tailscale
sudo systemctl stop navidrome-tailscale
```

## Troubleshooting

### Common Issues

#### Tailscale Authentication Failed
```bash
# Check auth key
grep TS_AUTHKEY .env

# Check Tailscale logs
docker compose logs tailscale

# Regenerate auth key if expired
# Visit: https://login.tailscale.com/admin/settings/keys
```

#### Navidrome Not Accessible
```bash
# Check Navidrome logs
docker compose logs navidrome

# Verify Tailscale IP
docker compose exec tailscale tailscale ip -4

# Test local access
curl http://localhost:4533/login
```

#### Permission Issues
```bash
# Check directory permissions
ls -la data/ music/ tailscale-state/

# Fix permissions if needed
sudo chown -R $USER:$USER data/ music/ tailscale-state/
```

#### Port Conflicts
If port 4533 is already in use:
```bash
# Check what's using the port
sudo netstat -tlnp | grep :4533

# Change port in docker-compose.yml if needed
# Note: Requires container restart
```

### Logs and Debugging

```bash
# All container logs
docker compose logs

# Follow logs in real-time
docker compose logs -f

# Tailscale debug info
docker compose exec tailscale tailscale status
docker compose exec tailscale tailscale ping <other-device>

# Navidrome debug
docker compose exec navidrome sh
# Inside container: tail /data/navidrome.log
```

## Backup and Recovery

### Data Backup
```bash
# Backup Navidrome data
tar -czf navidrome-backup-$(date +%Y%m%d).tar.gz data/

# Backup Tailscale state
tar -czf tailscale-backup-$(date +%Y%m%d).tar.gz tailscale-state/
```

### Recovery
```bash
# Stop services
./stop-tailscale-navidrome.sh

# Restore data
tar -xzf navidrome-backup-*.tar.gz
tar -xzf tailscale-backup-*.tar.gz

# Restart
./start-tailscale-navidrome.sh
```

## Performance Optimization

### Resource Limits
Add to `docker-compose.yml`:
```yaml
services:
  navidrome:
    deploy:
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M
```

### Music Library Optimization
- Use fast storage for `music/` directory
- Consider SSD for `data/` directory
- Use Docker volumes for better performance:
  ```yaml
  volumes:
    navidrome_data:
    navidrome_music:
  ```

## Security Considerations

1. **Auth Keys**: Rotate regularly, use short expiry
2. **ACLs**: Implement least-privilege access
3. **Updates**: Keep containers updated
4. **Firewall**: Restrict host firewall to necessary ports
5. **Secrets**: Store auth keys securely (not in repo)

## Advanced Configuration

### Subnet Router
Advertise host subnets:
```bash
# Add to .env
TS_ROUTES=192.168.1.0/24,10.0.0.0/24
```

### Custom Hostname
```bash
# Add to .env
TS_HOSTNAME=my-navidrome-server
```

### Exit Node
Make this node an exit node:
```yaml
# In docker-compose.yml tailscale service
environment:
  - TS_EXTRA_ARGS=--advertise-exit-node
```

## Support

- **Issues**: [GitHub Issues](https://github.com/Ev3lynx727/contained-navidrome-server/issues)
- **Navidrome**: [Navidrome Docs](https://www.navidrome.org/docs/)
- **Tailscale**: [Tailscale Docs](https://tailscale.com/kb/)

---

**Last updated**: December 2025