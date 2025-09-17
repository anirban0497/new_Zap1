let statusInterval;

// Check ZAP status on page load
document.addEventListener('DOMContentLoaded', function() {
    checkZapStatus();
});

function checkZapStatus() {
    const statusDiv = document.getElementById('zapStatus');
    statusDiv.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Checking ZAP connection...';
    statusDiv.className = 'alert alert-warning';
    
    fetch('/zap_status')
    .then(response => response.json())
    .then(data => {
        if (data.connected) {
            statusDiv.innerHTML = `<i class="fas fa-check-circle"></i> ${data.message}`;
            statusDiv.className = 'alert alert-success';
        } else {
            statusDiv.innerHTML = `<i class="fas fa-exclamation-triangle"></i> ZAP Connection Failed: ${data.message}<br>
                <small>Make sure ZAP is running on port 8081. <a href="#" onclick="showZapHelp()">Need help?</a></small>`;
            statusDiv.className = 'alert alert-danger';
        }
    })
    .catch(error => {
        statusDiv.innerHTML = `<i class="fas fa-times-circle"></i> Error checking ZAP status: ${error.message}`;
        statusDiv.className = 'alert alert-danger';
    });
}

function showZapHelp() {
    alert(`ZAP Setup Help:

1. Download OWASP ZAP from: https://www.zaproxy.org/download/
2. Start ZAP and change port to 8081:
   - Go to Tools → Options → Local Proxies
   - Change port from 8080 to 8081
   - Click OK
3. Or start ZAP from command line:
   zap.bat -daemon -port 8081
4. Verify ZAP is running by visiting: http://127.0.0.1:8081

For detailed instructions, check the ZAP_SETUP_GUIDE.md file in your project folder.`);
}

function debugScan() {
    const url = document.getElementById('targetUrl').value;
    
    if (!url) {
        alert('Please enter a target URL for debugging');
        return;
    }
    
    fetch('/debug_scan', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            url: url
        })
    })
    .then(response => response.json())
    .then(data => {
        let debugOutput = 'ZAP Debug Information:\n\n';
        for (const [key, value] of Object.entries(data)) {
            debugOutput += `${key}: ${value}\n`;
        }
        alert(debugOutput);
    })
    .catch(error => {
        alert('Debug request failed: ' + error.message);
    });
}

function downloadPDF() {
    const url = document.getElementById('targetUrl').value;
    
    if (!url) {
        alert('Please enter a target URL');
        return;
    }
    
    // Check if there are scan results
    const activeResults = document.getElementById('activeResults');
    if (!activeResults || activeResults.innerHTML.includes('No security issues found')) {
        alert('No scan results available. Please run a scan first.');
        return;
    }
    
    // Show loading indicator
    const downloadBtn = document.getElementById('downloadPdfBtn');
    const originalText = downloadBtn.innerHTML;
    downloadBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Generating PDF...';
    downloadBtn.disabled = true;
    
    fetch('/download_pdf', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            url: url
        })
    })
    .then(response => {
        if (!response.ok) {
            return response.json().then(err => Promise.reject(err));
        }
        return response.blob();
    })
    .then(blob => {
        // Create download link
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.style.display = 'none';
        a.href = url;
        
        // Generate filename with timestamp
        const timestamp = new Date().toISOString().slice(0, 19).replace(/:/g, '-');
        a.download = `vulnerability_report_${timestamp}.pdf`;
        
        document.body.appendChild(a);
        a.click();
        window.URL.revokeObjectURL(url);
        document.body.removeChild(a);
        
        showNotification('success', 'PDF report downloaded successfully!');
    })
    .catch(error => {
        console.error('PDF download failed:', error);
        showNotification('error', 'PDF download failed: ' + (error.error || error.message || 'Unknown error'));
    })
    .finally(() => {
        // Restore button
        downloadBtn.innerHTML = originalText;
        downloadBtn.disabled = false;
    });
}

function startScan(scanType) {
    const url = document.getElementById('targetUrl').value;
    
    if (!url) {
        alert('Please enter a target URL');
        return;
    }
    
    if (!isValidUrl(url)) {
        alert('Please enter a valid URL (must include http:// or https://)');
        return;
    }
    
    // Show progress section
    document.getElementById('progressSection').style.display = 'block';
    
    // Reset progress bars
    updateProgress('spider', 0);
    updateProgress('active', 0);
    
    fetch('/start_scan', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            url: url,
            scan_type: scanType
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.error) {
            alert('Error: ' + data.error);
        } else {
            showNotification('success', data.message);
            startStatusPolling();
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('Error starting scan: ' + error.message);
    });
}

function stopScan() {
    fetch('/stop_scan', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        }
    })
    .then(response => response.json())
    .then(data => {
        if (data.error) {
            alert('Error: ' + data.error);
        } else {
            showNotification('info', data.message);
            stopStatusPolling();
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('Error stopping scan: ' + error.message);
    });
}

function clearResults() {
    fetch('/clear_results', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        }
    })
    .then(response => response.json())
    .then(data => {
        showNotification('info', data.message);
        document.getElementById('spiderResults').innerHTML = '<p class="text-muted">No spider scan results yet</p>';
        document.getElementById('activeResults').innerHTML = '<p class="text-muted">No active scan results yet</p>';
        document.getElementById('progressSection').style.display = 'none';
    })
    .catch(error => {
        console.error('Error:', error);
        alert('Error clearing results: ' + error.message);
    });
}

function startStatusPolling() {
    if (statusInterval) {
        clearInterval(statusInterval);
    }
    
    statusInterval = setInterval(checkStatus, 2000);
}

function stopStatusPolling() {
    if (statusInterval) {
        clearInterval(statusInterval);
        statusInterval = null;
    }
}

function checkStatus() {
    fetch('/scan_status')
    .then(response => response.json())
    .then(data => {
        // Update spider progress
        updateProgress('spider', data.spider_progress);
        updateStatus('spider', data.spider_running, data.spider_progress);
        
        // Update active progress
        updateProgress('active', data.active_progress);
        updateStatus('active', data.active_running, data.active_progress);
        
        // Update results
        if (data.spider_results && data.spider_results.length > 0) {
            displaySpiderResults(data.spider_results);
        }
        
        if (data.active_results && data.active_results.length > 0) {
            displayActiveResults(data.active_results);
        }
        
        // Stop polling if no scans are running
        if (!data.spider_running && !data.active_running) {
            if (data.spider_progress === 100 || data.active_progress === 100) {
                setTimeout(() => {
                    stopStatusPolling();
                }, 3000); // Stop after 3 seconds to show final results
            }
        }
    })
    .catch(error => {
        console.error('Error checking status:', error);
    });
}

function updateProgress(scanType, progress) {
    const progressBar = document.getElementById(scanType + 'Progress');
    progressBar.style.width = progress + '%';
    progressBar.textContent = progress + '%';
}

function updateStatus(scanType, isRunning, progress) {
    const statusElement = document.getElementById(scanType + 'Status');
    
    if (isRunning) {
        statusElement.textContent = `Running... ${progress}%`;
        statusElement.className = 'text-primary';
    } else if (progress === 100) {
        statusElement.textContent = 'Completed';
        statusElement.className = 'text-success';
    } else {
        statusElement.textContent = 'Ready';
        statusElement.className = 'text-muted';
    }
}

function displaySpiderResults(results) {
    const container = document.getElementById('spiderResults');
    
    if (results.length === 0) {
        container.innerHTML = '<p class="text-muted">No URLs found</p>';
        return;
    }
    
    let html = `<p class="fw-bold">Found ${results.length} URLs:</p>`;
    
    results.forEach(url => {
        html += `<div class="url-found">${escapeHtml(url)}</div>`;
    });
    
    container.innerHTML = html;
}

function displayActiveResults(results) {
    const container = document.getElementById('activeResults');
    
    if (results.length === 0) {
        container.innerHTML = '<p class="text-muted">No security issues found</p>';
        return;
    }
    
    // Sort results by risk level (High -> Medium -> Low)
    const riskOrder = { 'High': 3, 'Medium': 2, 'Low': 1, 'Informational': 0 };
    results.sort((a, b) => (riskOrder[b.risk] || 0) - (riskOrder[a.risk] || 0));
    
    // Count vulnerabilities by risk level and category
    const riskCounts = {
        'High': results.filter(r => r.risk === 'High').length,
        'Medium': results.filter(r => r.risk === 'Medium').length,
        'Low': results.filter(r => r.risk === 'Low').length,
        'Informational': results.filter(r => r.risk === 'Informational').length
    };
    
    const categoryCounts = {};
    results.forEach(result => {
        if (result.category) {
            categoryCounts[result.category] = (categoryCounts[result.category] || 0) + 1;
        }
    });
    
    let html = `
        <div class="vulnerability-summary mb-4">
            <h6 class="fw-bold"><i class="fas fa-chart-pie"></i> Vulnerability Summary:</h6>
            <div class="row text-center mb-3">
                <div class="col-3"><span class="badge bg-danger fs-6">${riskCounts.High} High Risk</span></div>
                <div class="col-3"><span class="badge bg-warning fs-6">${riskCounts.Medium} Medium Risk</span></div>
                <div class="col-3"><span class="badge bg-success fs-6">${riskCounts.Low} Low Risk</span></div>
                <div class="col-3"><span class="badge bg-info fs-6">${riskCounts.Informational} Informational</span></div>
            </div>
    `;
    
    // Show category breakdown if available
    if (Object.keys(categoryCounts).length > 0) {
        html += '<h6 class="fw-bold"><i class="fas fa-tags"></i> Vulnerability Categories:</h6>';
        html += '<div class="row mb-3">';
        let colCount = 0;
        for (const [category, count] of Object.entries(categoryCounts)) {
            if (count > 0) {
                html += `<div class="col-md-4 col-sm-6 mb-2"><span class="badge bg-primary">${category}: ${count}</span></div>`;
                colCount++;
            }
        }
        html += '</div>';
    }
    
    html += '</div>';
    
    // Group vulnerabilities by category for better organization
    const groupedResults = {};
    results.forEach(result => {
        const category = result.category || 'Other';
        if (!groupedResults[category]) {
            groupedResults[category] = [];
        }
        groupedResults[category].push(result);
    });
    
    // Render grouped results
    Object.entries(groupedResults).forEach(([category, categoryResults]) => {
        if (categoryResults.length > 0) {
            html += `<div class="category-section mb-4">`;
            html += `<h5 class="category-header"><i class="fas fa-shield-alt"></i> ${category} (${categoryResults.length})</h5>`;
            
            categoryResults.forEach((alert, index) => {
                const risk = alert.risk || 'Unknown';
                const confidence = alert.confidence || 'Medium';
                const riskClass = getRiskClass(risk);
                const globalIndex = `${category}-${index}`;
                
                html += `
                    <div class="card mb-2 vulnerability-card">
                        <div class="card-header ${riskClass}" data-bs-toggle="collapse" data-bs-target="#vuln-active-${globalIndex}" style="cursor: pointer;">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <strong>${escapeHtml(alert.alert || 'Unknown Vulnerability')}</strong>
                                    ${alert.param ? `<small class="text-muted ms-2">Parameter: ${escapeHtml(alert.param)}</small>` : ''}
                                </div>
                                <div>
                                    <span class="badge bg-${getRiskBadgeColor(risk)} me-2">${risk}</span>
                                    <span class="badge bg-light text-dark">${confidence}</span>
                                    <i class="fas fa-chevron-down ms-2"></i>
                                </div>
                            </div>
                        </div>
                        <div id="vuln-active-${globalIndex}" class="collapse">
                            <div class="card-body">
                                <div class="row">
                                    <div class="col-md-8">
                                        <p><strong><i class="fas fa-link"></i> URL:</strong> <code class="text-break">${escapeHtml(alert.url || 'N/A')}</code></p>
                                        ${alert.method ? `<p><strong><i class="fas fa-exchange-alt"></i> Method:</strong> <span class="badge bg-secondary">${alert.method}</span></p>` : ''}
                                        ${alert.attack ? `<p><strong><i class="fas fa-bug"></i> Attack Vector:</strong> <code class="text-break">${escapeHtml(alert.attack)}</code></p>` : ''}
                                        <p><strong><i class="fas fa-info-circle"></i> Description:</strong> ${escapeHtml(alert.description || 'No description available')}</p>
                                        ${alert.evidence ? `<p><strong><i class="fas fa-search"></i> Evidence:</strong> <code class="text-break">${escapeHtml(alert.evidence)}</code></p>` : ''}
                                    </div>
                                    <div class="col-md-4">
                                        ${alert.cweid ? `<p><strong>CWE ID:</strong> <span class="badge bg-info">${alert.cweid}</span></p>` : ''}
                                        ${alert.wascid ? `<p><strong>WASC ID:</strong> <span class="badge bg-info">${alert.wascid}</span></p>` : ''}
                                        ${alert.pluginId ? `<p><strong>Plugin ID:</strong> <span class="badge bg-secondary">${alert.pluginId}</span></p>` : ''}
                                    </div>
                                </div>
                                ${alert.solution && alert.solution !== 'No solution provided' ? `
                                    <div class="alert alert-success mt-3">
                                        <strong><i class="fas fa-lightbulb"></i> Solution:</strong> ${escapeHtml(alert.solution)}
                                    </div>
                                ` : ''}
                                ${alert.reference ? `
                                    <div class="mt-3">
                                        <strong><i class="fas fa-external-link-alt"></i> Reference:</strong> 
                                        <a href="${alert.reference}" target="_blank" class="btn btn-outline-primary btn-sm">${alert.reference}</a>
                                    </div>
                                ` : ''}
                                ${alert.postdata ? `<p><strong><i class="fas fa-database"></i> POST Data:</strong> <code class="text-break">${escapeHtml(alert.postdata)}</code></p>` : ''}
                            </div>
                        </div>
                    </div>
                `;
            });
            
            html += '</div>';
        }
    });
    
    container.innerHTML = html;
}

function getRiskClass(risk) {
    switch (risk.toLowerCase()) {
        case 'high': return 'alert-high';
        case 'medium': return 'alert-medium';
        case 'low': return 'alert-low';
        case 'informational': return 'alert-low';
        default: return 'alert-medium';
    }
}

function getRiskBadgeColor(risk) {
    switch (risk.toLowerCase()) {
        case 'high': return 'danger';
        case 'medium': return 'warning';
        case 'low': return 'success';
        case 'informational': return 'info';
        default: return 'secondary';
    }
}

function isValidUrl(string) {
    try {
        new URL(string);
        return true;
    } catch (_) {
        return false;
    }
}

function escapeHtml(text) {
    const map = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#039;'
    };
    return text.replace(/[&<>"']/g, function(m) { return map[m]; });
}

function showNotification(message, type = 'info') {
    // Create a simple notification
    const notification = document.createElement('div');
    notification.className = `alert alert-${type === 'success' ? 'success' : type === 'error' ? 'danger' : 'info'} alert-dismissible fade show position-fixed`;
    notification.style.top = '20px';
    notification.style.right = '20px';
    notification.style.zIndex = '9999';
    notification.innerHTML = `
        ${message}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    `;
    
    document.body.appendChild(notification);
    
    // Auto-remove after 5 seconds
    setTimeout(() => {
        if (notification.parentNode) {
            notification.parentNode.removeChild(notification);
        }
    }, 5000);
}

function debugZAP() {
    fetch('/debug_scan')
        .then(response => response.json())
        .then(data => {
            console.log('Debug info:', data);
            if (data.error) {
                showNotification('Debug failed: ' + data.error, 'error');
            } else {
                showNotification(`Debug successful! ZAP v${data.zap_version}, ${data.total_alerts} alerts, ${data.total_urls} URLs`, 'success');
            }
        })
        .catch(error => {
            console.error('Debug error:', error);
            showNotification('Debug request failed', 'error');
        });
}

function forceResults() {
    showNotification('Forcing retrieval of scan results...', 'info');
    
    fetch('/force_results')
        .then(response => response.json())
        .then(data => {
            if (data.error) {
                showNotification('Force results failed: ' + data.error, 'error');
            } else {
                showNotification(`Successfully retrieved ${data.total_results} vulnerability findings!`, 'success');
                // Display the results immediately
                displayActiveResults(data.results);
            }
        })
        .catch(error => {
            console.error('Force results error:', error);
            showNotification('Force results request failed', 'error');
        });
}

function downloadPDF() {
    const downloadBtn = document.getElementById('downloadBtn');
    const originalText = downloadBtn.innerHTML;
    
    // Show loading state
    downloadBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Generating PDF...';
    downloadBtn.disabled = true;
    
    fetch('/download_pdf')
        .then(response => {
            if (response.ok) {
                return response.blob();
            } else {
                return response.json().then(err => Promise.reject(err));
            }
        })
        .then(blob => {
            // Create download link
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.style.display = 'none';
            a.href = url;
            a.download = `vulnerability_report_${new Date().toISOString().slice(0,19).replace(/:/g, '-')}.pdf`;
            document.body.appendChild(a);
            a.click();
            window.URL.revokeObjectURL(url);
            document.body.removeChild(a);
            
            showNotification('PDF report downloaded successfully!', 'success');
        })
        .catch(error => {
            console.error('PDF download error:', error);
            showNotification('PDF download failed: ' + (error.error || 'Unknown error'), 'error');
        })
        .finally(() => {
            // Restore button state
            downloadBtn.innerHTML = originalText;
            downloadBtn.disabled = false;
        });
}
