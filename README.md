# Contained Navidrome Server

A self-hosted music server with Docker, VPN integration, and automated CI/CD.

## Overview

This project provides a complete Navidrome music server setup with:
- Docker containerization
- Host-based OpenVPN client for secure remote access
- SOCKS proxy for traffic forwarding
- Automated CI/CD with GitHub Actions
- Comprehensive testing and security scanning

## Features

- 🎵 **Navidrome Music Server**: Stream your personal music collection
- 🔐 **VPN Integration**: Secure remote access through OpenVPN
- 🚀 **Automated CI/CD**: GitHub Actions with testing and security scanning
- 🐳 **Docker Ready**: Complete containerization with Compose
- 📊 **Monitoring**: Health checks and automated VPN reconnection
- 🔒 **Security**: Trivy vulnerability scanning and security best practices

## Quick Start

### Automated Setup (Recommended)
```bash
# Clone the repository
git clone https://github.com/Ev3lynx727/contained-navidrome-server.git
cd contained-navidrome-server

# Run automated setup
./auto-setup-vpn.sh
```

This will:
- Install systemd service for auto-startup
- Set up cron monitoring for VPN health
- Test VPN connection
- Configure SOCKS proxy
- Create desktop shortcuts

### Manual Setup
```bash
# Start Navidrome locally
./run-container.sh

# Or start with VPN
./start-vpn-navidrome.sh
```

## Prerequisites

- Docker and Docker Compose
- Access to VPN infrastructure (existing setup)
- Linux system (for systemd/cron features)

## Project Structure

```
contained-navidrome-server/
├── .github/               # GitHub Actions workflows
├── .gitignore            # Git ignore rules
├── .dockerignore         # Docker build exclusions
├── Makefile              # Development commands
├── docker-compose.yml    # Container configuration
├── .env                  # Environment variables
├── README.md            # This file
├── data/                # Persistent Navidrome data
├── music/               # Music files directory
├── vpn-config/          # VPN client configuration
├── auto-setup-vpn.sh    # Automated setup script
├── start-vpn-navidrome.sh # VPN + Navidrome startup
├── stop-vpn-navidrome.sh # Clean shutdown
├── host-ovpn-connect.sh # VPN connection management
├── setup-socks-proxy.sh # SOCKS proxy setup
├── vpn-monitor.sh       # VPN health monitoring
├── setup-cron-monitoring.sh # Cron job setup
├── install-vpn-service.sh # Systemd service installer
├── navidrome-vpn.service # Systemd service definition
└── test-setup.sh        # Test suite
```

## Configuration

### Environment Variables (.env)
```bash
# Navidrome settings
ND_MUSICFOLDER=/music
ND_DATAFOLDER=/data

# Optional: Admin password (leave empty for no password)
ND_PASSWORD=your_secure_password
```

### VPN Configuration
- VPN config: `vpn-config/vpn.conf`
- Server: Configured in existing VPN setup
- Client certificates: Included in config

## Usage

### Development
```bash
# Show all commands
make help

# Start services
make up

# Run tests
make test

# View logs
make logs
```

### VPN Management
```bash
# Check VPN status
./host-ovpn-connect.sh status

# Start VPN monitoring
./vpn-monitor.sh monitor

# Check proxy status
./setup-socks-proxy.sh status
```

### System Integration
```bash
# Install systemd service (auto-start VPN)
sudo ./install-vpn-service.sh

# Setup cron monitoring
./setup-cron-monitoring.sh
```

## Access Points

- **Local Access**: `http://localhost:4533`
- **VPN Access**: Connect to VPN first, then access `http://localhost:4533`
- **Admin Login**: Username: `admin`, Password: (configured in .env)

## CI/CD Pipeline

### Automated Testing
- Docker Compose validation
- Container startup verification
- HTTP endpoint testing
- Service health checks

### Quality Assurance
- Shell script linting (shellcheck)
- YAML validation
- Security vulnerability scanning (Trivy)

### Deployment
- Automated Docker builds on releases
- Build provenance attestation
- Multi-platform support

## Security Features

- VPN-only remote access
- Container isolation
- Automated security scanning
- No public ports exposed
- Encrypted traffic end-to-end

## Troubleshooting

### Common Issues

**VPN Connection Failed**
```bash
# Check VPN logs
./host-ovpn-connect.sh status

# Restart VPN
./host-ovpn-connect.sh restart
```

**Container Won't Start**
```bash
# Check Docker logs
docker compose logs

# Validate configuration
docker compose config
```

**Permission Errors**
```bash
# Run with sudo for system operations
sudo ./install-vpn-service.sh
```

### Logs and Monitoring
```bash
# VPN connection logs
tail -f vpn-connection.log

# SOCKS proxy logs
tail -f socks-proxy.log

# VPN monitoring logs
tail -f vpn-monitor.log
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes with tests
4. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

- 📖 [Navidrome Documentation](https://www.navidrome.org/docs/)
- 🐛 [Issues](https://github.com/Ev3lynx727/contained-navidrome-server/issues)
- 💬 [Discussions](https://github.com/Ev3lynx727/contained-navidrome-server/discussions)

---

**Built with ❤️ for self-hosted music streaming**