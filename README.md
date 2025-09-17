# ZAP Security Scanner Web Application

A web-based interface for OWASP ZAP (Zed Attack Proxy) security testing that allows users to perform automated security scans on web applications.

## Features

- **Spider Scan**: Crawls the target website to discover URLs and pages
- **Active Scan**: Performs security vulnerability testing on discovered pages
- **Full Scan**: Combines both spider and active scanning
- **Real-time Progress**: Live updates on scan progress
- **Results Display**: Formatted display of discovered URLs and security alerts
- **Modern UI**: Clean, responsive Bootstrap-based interface

## Prerequisites

1. **OWASP ZAP**: Download and install from [https://www.zaproxy.org/download/](https://www.zaproxy.org/download/)
2. **Python 3.7+**: Required for running the Flask application

## Installation

1. Clone or download this project
2. Install Python dependencies:
   ```bash
   pip install -r requirements.txt
   ```

## Setup

1. **Start OWASP ZAP**:
   - Launch ZAP in daemon mode or with API enabled
   - Default configuration expects ZAP running on `127.0.0.1:8081`
   - To start ZAP in headless mode: `zap.sh -daemon -port 8081`

2. **Configure ZAP API** (if needed):
   - The application uses ZAP's default API configuration
   - If you've changed ZAP's port or API settings, update the `ZAP_PROXY` configuration in `app.py`

## Usage

1. **Start the Flask application**:
   ```bash
   python app.py
   ```

2. **Access the web interface**:
   - Open your browser and go to `http://localhost:5000`

3. **Perform security scans**:
   - Enter the target URL (must include http:// or https://)
   - Choose scan type:
     - **Spider Scan**: Discovers URLs and site structure
     - **Active Scan**: Tests for security vulnerabilities
     - **Full Scan**: Runs both spider and active scans sequentially
   - Monitor real-time progress
   - View results in the respective panels

## Security Considerations

- **Only test applications you own or have explicit permission to test**
- **Never run scans against production systems without proper authorization**
- **Be aware that active scans may modify application data**
- **Consider rate limiting and scan intensity for production-like environments**

## API Endpoints

- `GET /`: Main web interface
- `POST /start_scan`: Start a security scan
- `GET /scan_status`: Get current scan status and progress
- `POST /stop_scan`: Stop all running scans
- `POST /clear_results`: Clear scan results

## Troubleshooting

1. **ZAP Connection Issues**:
   - Ensure ZAP is running and accessible on port 8081
   - Check firewall settings
   - Verify ZAP API is enabled

2. **Scan Failures**:
   - Ensure target URL is accessible
   - Check if target site blocks automated tools
   - Verify URL format (must include protocol)

3. **Performance Issues**:
   - Large sites may take considerable time to scan
   - Consider using ZAP's scan policies to adjust intensity
   - Monitor system resources during scans

## License

This project is for educational and authorized security testing purposes only.
