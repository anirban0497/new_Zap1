#!/usr/bin/env python3
"""
Debug script to test ZAP connection from within the container
"""

import socket
import time
import requests
from zapv2 import ZAPv2

def test_socket_connection():
    """Test raw socket connection to ZAP"""
    print("=== Socket Connection Test ===")
    
    hosts = ['127.0.0.1', 'localhost', '0.0.0.0']
    for host in hosts:
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(5)
            result = sock.connect_ex((host, 8081))
            sock.close()
            
            if result == 0:
                print(f"✓ Socket connection to {host}:8081 successful")
            else:
                print(f"✗ Socket connection to {host}:8081 failed (error: {result})")
        except Exception as e:
            print(f"✗ Socket test to {host}:8081 exception: {e}")

def test_http_connection():
    """Test HTTP connection to ZAP"""
    print("\n=== HTTP Connection Test ===")
    
    hosts = ['127.0.0.1', 'localhost', '0.0.0.0']
    for host in hosts:
        try:
            response = requests.get(f'http://{host}:8081/', timeout=5)
            print(f"✓ HTTP connection to {host}:8081 successful (status: {response.status_code})")
        except Exception as e:
            print(f"✗ HTTP connection to {host}:8081 failed: {e}")

def test_zap_api():
    """Test ZAP API connection"""
    print("\n=== ZAP API Test ===")
    
    api_key = 'n8j4egcp9764kits0iojhf7kk5'
    hosts = ['127.0.0.1', 'localhost', '0.0.0.0']
    
    for host in hosts:
        try:
            # Test with requests directly
            url = f'http://{host}:8081/JSON/core/view/version/?apikey={api_key}'
            response = requests.get(url, timeout=10)
            if response.status_code == 200:
                data = response.json()
                version = data.get('version', 'unknown')
                print(f"✓ ZAP API on {host}:8081 successful (version: {version})")
            else:
                print(f"✗ ZAP API on {host}:8081 failed (status: {response.status_code})")
        except Exception as e:
            print(f"✗ ZAP API on {host}:8081 exception: {e}")

def test_zapv2_client():
    """Test ZAPv2 client connection"""
    print("\n=== ZAPv2 Client Test ===")
    
    api_key = 'n8j4egcp9764kits0iojhf7kk5'
    hosts = ['127.0.0.1', 'localhost']
    
    for host in hosts:
        try:
            # Test with proxy configuration (original method)
            print(f"Testing {host} with proxy config...")
            zap_proxy = ZAPv2(
                apikey=api_key,
                proxies={'http': f'http://{host}:8081', 'https': f'http://{host}:8081'}
            )
            version = zap_proxy.core.version
            print(f"✓ ZAPv2 proxy client on {host}:8081 successful (version: {version})")
        except Exception as e:
            print(f"✗ ZAPv2 proxy client on {host}:8081 failed: {e}")
        
        try:
            # Test without proxy configuration (new method)
            print(f"Testing {host} without proxy config...")
            zap_direct = ZAPv2(apikey=api_key, proxies=None)
            zap_direct._ZAPv2__base = f'http://{host}:8081'
            version = zap_direct.core.version
            print(f"✓ ZAPv2 direct client on {host}:8081 successful (version: {version})")
        except Exception as e:
            print(f"✗ ZAPv2 direct client on {host}:8081 failed: {e}")

def main():
    print("ZAP Connection Debug Script")
    print("=" * 50)
    
    # Wait a moment for ZAP to be ready
    print("Waiting 10 seconds for ZAP to be ready...")
    time.sleep(10)
    
    test_socket_connection()
    test_http_connection()
    test_zap_api()
    test_zapv2_client()
    
    print("\n" + "=" * 50)
    print("Debug complete")

if __name__ == "__main__":
    main()
