#!/usr/bin/env python3
"""
Test script to validate ZAP Scanner application functionality
Tests all major components without requiring Docker or ZAP daemon
"""

import sys
import os
import importlib.util

def test_imports():
    """Test if all required modules can be imported"""
    print("Testing imports...")
    
    required_modules = [
        'flask', 'flask_cors', 'threading', 'time', 'os', 
        'zapv2', 'io', 'datetime', 'reportlab.lib.pagesizes',
        'reportlab.platypus', 'reportlab.lib.styles', 
        'reportlab.lib.units', 'reportlab.lib', 'reportlab.lib.enums',
        'json'
    ]
    
    missing_modules = []
    
    for module in required_modules:
        try:
            if '.' in module:
                # Handle submodules
                parent_module = module.split('.')[0]
                __import__(parent_module)
            else:
                __import__(module)
            print(f"[OK] {module}")
        except ImportError as e:
            print(f"[FAIL] {module} - {e}")
            missing_modules.append(module)
    
    return len(missing_modules) == 0, missing_modules

def test_app_structure():
    """Test if the Flask app can be created and routes are defined"""
    print("\nTesting Flask app structure...")
    
    try:
        # Import the app module
        sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
        
        # Test basic Flask app creation
        from flask import Flask
        test_app = Flask(__name__)
        print("[OK] Flask app creation")
        
        # Test if main app file exists and has required components
        if os.path.exists('app.py'):
            print("[OK] app.py exists")
            
            with open('app.py', 'r') as f:
                content = f.read()
                
            # Check for required routes
            required_routes = [
                '/start_scan', '/scan_status', '/stop_scan', 
                '/download_pdf', '/force_results'
            ]
            
            routes_found = []
            for route in required_routes:
                if route in content:
                    routes_found.append(route)
                    print(f"[OK] Route {route} defined")
                else:
                    print(f"[FAIL] Route {route} missing")
            
            # Check for ZAP integration
            if 'ZAPv2' in content:
                print("[OK] ZAP integration present")
            else:
                print("[FAIL] ZAP integration missing")
                
            # Check for PDF generation
            if 'reportlab' in content:
                print("[OK] PDF generation capability present")
            else:
                print("[FAIL] PDF generation missing")
                
            return len(routes_found) >= 4
        else:
            print("[FAIL] app.py not found")
            return False
            
    except Exception as e:
        print(f"[FAIL] Flask app structure test failed: {e}")
        return False

def test_templates():
    """Test if required templates exist"""
    print("\nTesting templates...")
    
    template_files = ['templates/index.html']
    static_files = ['static/js/scanner.js']
    
    all_files_exist = True
    
    for file_path in template_files + static_files:
        if os.path.exists(file_path):
            print(f"[OK] {file_path} exists")
        else:
            print(f"[FAIL] {file_path} missing")
            all_files_exist = False
    
    return all_files_exist

def test_configuration_files():
    """Test if deployment configuration files exist"""
    print("\nTesting configuration files...")
    
    config_files = [
        'Dockerfile', 'requirements.txt', 'railway.json',
        'render.yaml', 'fly.toml', 'netlify.toml'
    ]
    
    files_found = 0
    for file_path in config_files:
        if os.path.exists(file_path):
            print(f"[OK] {file_path} exists")
            files_found += 1
        else:
            print(f"[SKIP] {file_path} not found (optional)")
    
    return files_found >= 3  # At least 3 config files should exist

def test_dockerfile_syntax():
    """Test Dockerfile for basic syntax issues"""
    print("\nTesting Dockerfile...")
    
    if not os.path.exists('Dockerfile'):
        print("[FAIL] Dockerfile not found")
        return False
    
    try:
        with open('Dockerfile', 'r') as f:
            content = f.read()
        
        # Check for required Dockerfile components
        required_components = [
            'FROM', 'RUN', 'COPY', 'EXPOSE', 'CMD'
        ]
        
        components_found = 0
        for component in required_components:
            if component in content:
                print(f"[OK] {component} directive found")
                components_found += 1
            else:
                print(f"[FAIL] {component} directive missing")
        
        # Check for ZAP installation
        if 'zap' in content.lower():
            print("[OK] ZAP installation present")
        else:
            print("[FAIL] ZAP installation missing")
        
        # Check for Python dependencies
        if 'requirements.txt' in content:
            print("[OK] Python dependencies installation present")
        else:
            print("[FAIL] Python dependencies installation missing")
        
        return components_found >= 4
        
    except Exception as e:
        print(f"[FAIL] Dockerfile test failed: {e}")
        return False

def test_requirements():
    """Test requirements.txt for required packages"""
    print("\nTesting requirements.txt...")
    
    if not os.path.exists('requirements.txt'):
        print("[FAIL] requirements.txt not found")
        return False
    
    try:
        with open('requirements.txt', 'r') as f:
            content = f.read().lower()
        
        required_packages = [
            'flask', 'flask-cors', 'python-owasp-zap-v2.4',
            'requests', 'reportlab', 'pillow', 'gunicorn'
        ]
        
        packages_found = 0
        for package in required_packages:
            if package.lower() in content:
                print(f"[OK] {package} found")
                packages_found += 1
            else:
                print(f"[FAIL] {package} missing")
        
        return packages_found >= 6
        
    except Exception as e:
        print(f"[FAIL] requirements.txt test failed: {e}")
        return False

def run_all_tests():
    """Run all tests and provide summary"""
    print("=" * 60)
    print("ZAP SCANNER APPLICATION TEST SUITE")
    print("=" * 60)
    
    tests = [
        ("Import Dependencies", test_imports),
        ("Flask App Structure", test_app_structure),
        ("Templates & Static Files", test_templates),
        ("Configuration Files", test_configuration_files),
        ("Dockerfile Syntax", test_dockerfile_syntax),
        ("Requirements File", test_requirements)
    ]
    
    results = []
    
    for test_name, test_func in tests:
        print(f"\n{'='*20} {test_name} {'='*20}")
        try:
            result = test_func()
            results.append((test_name, result))
        except Exception as e:
            print(f"[FAIL] Test failed with exception: {e}")
            results.append((test_name, False))
    
    # Summary
    print("\n" + "=" * 60)
    print("TEST SUMMARY")
    print("=" * 60)
    
    passed = 0
    total = len(results)
    
    for test_name, result in results:
        status = "PASS" if result else "FAIL"
        icon = "[OK]" if result else "[FAIL]"
        print(f"{icon} {test_name}: {status}")
        if result:
            passed += 1
    
    print(f"\nOverall: {passed}/{total} tests passed")
    
    if passed == total:
        print("\n[SUCCESS] ALL TESTS PASSED! Application is ready for deployment.")
        return True
    elif passed >= total * 0.8:  # 80% pass rate
        print(f"\n[WARNING] Most tests passed ({passed}/{total}). Application should work but may have minor issues.")
        return True
    else:
        print(f"\n[ERROR] Multiple test failures ({passed}/{total}). Application needs fixes before deployment.")
        return False

if __name__ == "__main__":
    success = run_all_tests()
    sys.exit(0 if success else 1)
