# Contained Navidrome Server

A self-hosted music server with Docker, Tailscale VPN integration, and automated CI/CD.

## Overview

This project provides a complete Navidrome music server setup with:
- Docker containerization
- Tailscale mesh VPN for secure remote access
- Zero-config networking with automatic peer discovery
- Automated CI/CD with GitHub Actions
- Comprehensive testing and security scanning

## Features

- 🎵 **Navidrome Music Server**: Stream your personal music collection
- 🔐 **Tailscale VPN**: Secure remote access through WireGuard-based mesh networking
- 🚀 **Automated CI/CD**: GitHub Actions with testing and security scanning
- 🐳 **Docker Ready**: Complete containerization with Compose
- 📊 **Monitoring**: Health checks and Tailscale connection monitoring
- 🔒 **Security**: Trivy vulnerability scanning and zero-trust networking

## Quick Start

### Automated Setup (Recommended)
```bash
# Clone the repository
git clone https://github.com/Ev3lynx727/contained-navidrome-server.git
cd contained-navidrome-server

# Install Tailscale
./install-tailscale.sh

# Setup and authenticate Tailscale
./setup-tailscale.sh

# Start services
./start-tailscale-navidrome.sh
```

This will:
- Install Tailscale on your system
- Authenticate with your Tailscale network
- Start Navidrome with secure remote access
- Provide access information for remote connections

### Manual Setup
```bash
# Install Tailscale (if not already installed)
./install-tailscale.sh

# Setup Tailscale authentication
./setup-tailscale.sh

# Start Navidrome with Tailscale
./start-tailscale-navidrome.sh
```

## Prerequisites

- Docker and Docker Compose
- Tailscale account and network access
- Linux system (for systemd features)

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
├── install-tailscale.sh # Tailscale installation
├── setup-tailscale.sh   # Tailscale authentication
├── start-tailscale-navidrome.sh # Start both services
├── stop-tailscale-navidrome.sh  # Stop services
├── tailscale-monitor.sh # Connection monitoring
├── navidrome-tailscale.service # Systemd service definition
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

### Tailscale Configuration
- Authentication: Via auth key or interactive login
- Hostname: Configurable for easy identification
- Routes: Optional subnet advertising
- DNS: Optional acceptance of Tailscale DNS

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

### Tailscale Management
```bash
# Check Tailscale status
./tailscale-monitor.sh status

# Start connection monitoring
./tailscale-monitor.sh monitor

# Get Tailscale IP
tailscale ip
```

### System Integration
```bash
# Install systemd service (auto-start with Tailscale)
sudo cp navidrome-tailscale.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable navidrome-tailscale

# Monitor Tailscale connection
./tailscale-monitor.sh monitor
```

## Access Points

- **Local Access**: `http://localhost:4533`
- **Tailscale Access**: `http://<tailscale-ip>:4533` (anywhere on your Tailscale network)
- **Admin Login**: Username: `admin`, Password: (configured in .env or empty)

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

- Tailscale mesh VPN for secure remote access
- Container isolation
- Automated security scanning
- No public ports exposed
- WireGuard encryption end-to-end

## Troubleshooting

### Common Issues

**Tailscale Connection Failed**
```bash
# Check Tailscale status
tailscale status

# Restart Tailscale
sudo systemctl restart tailscaled
sudo tailscale up
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
sudo ./install-tailscale.sh
```

### Logs and Monitoring
```bash
# Tailscale logs
sudo journalctl -u tailscaled -f

# Docker container logs
docker compose logs -f navidrome

# Tailscale connection monitoring
./tailscale-monitor.sh monitor
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