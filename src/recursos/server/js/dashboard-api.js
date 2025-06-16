// SENA Agro Reg - Dashboard API Client
// Handles all API communications for the dashboard

class DashboardAPI {
    constructor() {
        this.baseURL = '';
        this.token = this.getCookie('auth_token');
    }

    // Utility function to get cookie
    getCookie(name) {
        const value = `; ${document.cookie}`;
        const parts = value.split(`; ${name}=`);
        if (parts.length === 2) return parts.pop().split(';').shift();
        return null;
    }

    // Utility function to set cookie
    setCookie(name, value, days = 7) {
        const expires = new Date();
        expires.setTime(expires.getTime() + (days * 24 * 60 * 60 * 1000));
        document.cookie = `${name}=${value};expires=${expires.toUTCString()};path=/`;
    }

    // Utility function to delete cookie
    deleteCookie(name) {
        document.cookie = `${name}=;expires=Thu, 01 Jan 1970 00:00:00 UTC;path=/`;
    }

    // Generic API request method
    async request(endpoint, options = {}) {
        const config = {
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${this.token}`,
                ...options.headers
            },
            ...options
        };

        try {
            const response = await fetch(`${this.baseURL}${endpoint}`, config);

            if (!response.ok) {
                if (response.status === 401) {
                    // Token expired or invalid
                    this.redirectToLogin();
                    throw new Error('Authentication failed');
                }
                throw new Error(`HTTP error! status: ${response.status}`);
            }

            const data = await response.json();
            return data;
        } catch (error) {
            console.error('API request failed:', error);
            throw error;
        }
    }

    // Authentication methods
    async verifyToken() {
        return this.request('/api/auth/verify', {
            method: 'POST',
            body: JSON.stringify({ token: this.token })
        });
    }

    async logout() {
        try {
            await this.request('/api/auth/logout', {
                method: 'POST'
            });
        } catch (error) {
            console.error('Logout request failed:', error);
        } finally {
            this.deleteCookie('auth_token');
            this.redirectToLogin();
        }
    }

    redirectToLogin() {
        window.location.href = '/login';
    }

    // Permission methods
    async getPermissions(module) {
        return this.request(`/api/permissions/${module}`);
    }

    async getAllPermissions() {
        const modules = ['users', 'inventory', 'reminders', 'roles', 'sessions', 'events'];
        const permissions = {};

        for (const module of modules) {
            try {
                const result = await this.getPermissions(module);
                permissions[module] = result.permission;
            } catch (error) {
                permissions[module] = 'none';
            }
        }

        return permissions;
    }

    // User management methods
    async getUsers() {
        return this.request('/api/users');
    }

    async createUser(userData) {
        return this.request('/api/users', {
            method: 'POST',
            body: JSON.stringify(userData)
        });
    }

    async updateUser(userId, userData) {
        return this.request(`/api/users/${userId}`, {
            method: 'PUT',
            body: JSON.stringify(userData)
        });
    }

    async deleteUser(userId) {
        return this.request(`/api/users/${userId}`, {
            method: 'DELETE'
        });
    }

    async getUserStats() {
        return this.request('/api/users/stats');
    }

    // Inventory management methods
    async getInventory() {
        return this.request('/api/inventory');
    }

    async createInventoryItem(itemData) {
        return this.request('/api/inventory', {
            method: 'POST',
            body: JSON.stringify(itemData)
        });
    }

    async updateInventoryItem(itemId, itemData) {
        return this.request(`/api/inventory/${itemId}`, {
            method: 'PUT',
            body: JSON.stringify(itemData)
        });
    }

    async deleteInventoryItem(itemId) {
        return this.request(`/api/inventory/${itemId}`, {
            method: 'DELETE'
        });
    }

    async getInventoryStats() {
        return this.request('/api/inventory/stats');
    }

    // Reminder management methods
    async getReminders() {
        return this.request('/api/reminders');
    }

    async createReminder(reminderData) {
        return this.request('/api/reminders', {
            method: 'POST',
            body: JSON.stringify(reminderData)
        });
    }

    async updateReminder(reminderId, reminderData) {
        return this.request(`/api/reminders/${reminderId}`, {
            method: 'PUT',
            body: JSON.stringify(reminderData)
        });
    }

    async deleteReminder(reminderId) {
        return this.request(`/api/reminders/${reminderId}`, {
            method: 'DELETE'
        });
    }

    async toggleReminder(reminderId) {
        return this.request(`/api/reminders/${reminderId}/toggle`, {
            method: 'POST'
        });
    }

    async getReminderStats() {
        return this.request('/api/reminders/stats');
    }

    // Role management methods
    async getRoles() {
        return this.request('/api/roles');
    }

    async createRole(roleData) {
        return this.request('/api/roles', {
            method: 'POST',
            body: JSON.stringify(roleData)
        });
    }

    async updateRole(rolePosition, roleData) {
        return this.request(`/api/roles/${rolePosition}`, {
            method: 'PUT',
            body: JSON.stringify(roleData)
        });
    }

    async deleteRole(rolePosition) {
        return this.request(`/api/roles/${rolePosition}`, {
            method: 'DELETE'
        });
    }

    async getRoleUsers(rolePosition) {
        return this.request(`/api/roles/${rolePosition}/users`);
    }

    // Session management methods
    async getSessions() {
        return this.request('/api/sessions');
    }

    async deleteSession(sessionId) {
        return this.request(`/api/sessions/${sessionId}`, {
            method: 'DELETE'
        });
    }

    async clearExpiredSessions() {
        return this.request('/api/sessions/clear-expired', {
            method: 'POST'
        });
    }

    async getSessionStats() {
        return this.request('/api/sessions/stats');
    }

    // Event management methods
    async getEvents(filters = {}) {
        const params = new URLSearchParams();
        Object.keys(filters).forEach(key => {
            if (filters[key]) {
                params.append(key, filters[key]);
            }
        });

        const queryString = params.toString();
        return this.request(`/api/events${queryString ? '?' + queryString : ''}`);
    }

    async getEventStats() {
        return this.request('/api/events/stats');
    }

    async createEvent(eventData) {
        return this.request('/api/events', {
            method: 'POST',
            body: JSON.stringify(eventData)
        });
    }

    // Utility methods for role handling
    parseRoles(rolesBitmask) {
        const roles = [];
        for (let i = 0; i < 64; i++) {
            if (rolesBitmask & (1 << i)) {
                roles.push(i + 1);
            }
        }
        return roles;
    }

    buildRolesBitmask(rolePositions) {
        let bitmask = 0;
        rolePositions.forEach(position => {
            bitmask |= (1 << (position - 1));
        });
        return bitmask;
    }

    // Format date from epoch
    formatDate(epochTime) {
        if (!epochTime) return 'N/A';
        const date = new Date(epochTime * 1000);
        return date.toLocaleString('es-ES');
    }

    // Format currency
    formatCurrency(amount) {
        return new Intl.NumberFormat('es-CO', {
            style: 'currency',
            currency: 'COP'
        }).format(amount);
    }

    // Search and filter utilities
    searchTable(searchTerm, tableId, columns = []) {
        const table = document.getElementById(tableId);
        const rows = table.querySelectorAll('tbody tr');

        rows.forEach(row => {
            const cells = row.querySelectorAll('td');
            let found = false;

            cells.forEach((cell, index) => {
                if (columns.length === 0 || columns.includes(index)) {
                    if (cell.textContent.toLowerCase().includes(searchTerm.toLowerCase())) {
                        found = true;
                    }
                }
            });

            row.style.display = found ? '' : 'none';
        });
    }

    // Loading states
    showLoading(elementId) {
        const element = document.getElementById(elementId);
        if (element) {
            element.innerHTML = '<div class="text-center"><div class="spinner-border" role="status"></div></div>';
        }
    }

    hideLoading(elementId) {
        const element = document.getElementById(elementId);
        if (element) {
            element.innerHTML = '';
        }
    }

    // Error handling
    showError(message, containerId = 'error-container') {
        const container = document.getElementById(containerId);
        if (container) {
            container.innerHTML = `
                <div class="alert alert-danger alert-dismissible">
                    <strong>Error:</strong> ${message}
                    <button type="button" class="close-btn" onclick="this.parentElement.remove()">&times;</button>
                </div>
            `;
        } else {
            console.error('Error:', message);
            alert('Error: ' + message);
        }
    }

    // Success messages
    showSuccess(message, containerId = 'success-container') {
        const container = document.getElementById(containerId);
        if (container) {
            container.innerHTML = `
                <div class="alert alert-success alert-dismissible">
                    <strong>Éxito:</strong> ${message}
                    <button type="button" class="close-btn" onclick="this.parentElement.remove()">&times;</button>
                </div>
            `;

            // Auto-hide after 5 seconds
            setTimeout(() => {
                const alert = container.querySelector('.alert');
                if (alert) {
                    alert.remove();
                }
            }, 5000);
        }
    }

    // Form validation
    validateForm(formId) {
        const form = document.getElementById(formId);
        const inputs = form.querySelectorAll('input[required], select[required], textarea[required]');
        let isValid = true;

        inputs.forEach(input => {
            if (!input.value.trim()) {
                input.classList.add('is-invalid');
                isValid = false;
            } else {
                input.classList.remove('is-invalid');
                input.classList.add('is-valid');
            }
        });

        return isValid;
    }

    // Clear form
    clearForm(formId) {
        const form = document.getElementById(formId);
        form.reset();

        // Remove validation classes
        const inputs = form.querySelectorAll('input, select, textarea');
        inputs.forEach(input => {
            input.classList.remove('is-valid', 'is-invalid');
        });
    }

    // Get form data as object
    getFormData(formId) {
        const form = document.getElementById(formId);
        const formData = new FormData(form);
        const data = {};

        for (let [key, value] of formData.entries()) {
            data[key] = value;
        }

        return data;
    }

    // Populate form with data
    populateForm(formId, data) {
        const form = document.getElementById(formId);

        Object.keys(data).forEach(key => {
            const input = form.querySelector(`[name="${key}"], #${key}`);
            if (input) {
                if (input.type === 'checkbox') {
                    input.checked = data[key];
                } else {
                    input.value = data[key];
                }
            }
        });
    }

    // Debounce function for search
    debounce(func, wait) {
        let timeout;
        return function executedFunction(...args) {
            const later = () => {
                clearTimeout(timeout);
                func(...args);
            };
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
        };
    }

    // Export data to CSV
    exportToCSV(data, filename) {
        const csv = this.convertToCSV(data);
        const blob = new Blob([csv], { type: 'text/csv' });
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = filename;
        a.click();
        window.URL.revokeObjectURL(url);
    }

    convertToCSV(data) {
        if (!data || !data.length) return '';

        const headers = Object.keys(data[0]);
        const csvHeaders = headers.join(',');

        const csvRows = data.map(row => {
            return headers.map(header => {
                const value = row[header];
                return typeof value === 'string' && value.includes(',') ? `"${value}"` : value;
            }).join(',');
        });

        return [csvHeaders, ...csvRows].join('\n');
    }

    // Confirm dialog
    confirm(message, callback) {
        if (window.confirm(message)) {
            callback();
        }
    }

    // Toast notifications
    showToast(message, type = 'info') {
        const toast = document.createElement('div');
        toast.className = `alert alert-${type} toast-notification`;
        toast.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            z-index: 9999;
            min-width: 300px;
            opacity: 0;
            transition: opacity 0.3s ease;
        `;
        toast.innerHTML = `
            ${message}
            <button type="button" class="close-btn" onclick="this.parentElement.remove()">&times;</button>
        `;

        document.body.appendChild(toast);

        // Fade in
        setTimeout(() => {
            toast.style.opacity = '1';
        }, 100);

        // Auto-remove after 5 seconds
        setTimeout(() => {
            toast.style.opacity = '0';
            setTimeout(() => {
                if (toast.parentNode) {
                    toast.parentNode.removeChild(toast);
                }
            }, 300);
        }, 5000);
    }
}

// Create global instance
const dashboardAPI = new DashboardAPI();

// Export for use in other files
if (typeof module !== 'undefined' && module.exports) {
    module.exports = DashboardAPI;
}
