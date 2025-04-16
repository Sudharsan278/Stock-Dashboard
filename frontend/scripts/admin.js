document.addEventListener('DOMContentLoaded', function() {
    const isAdmin = localStorage.getItem('isAdmin') === 'true' || 
                    document.cookie.split('; ').find(row => row.startsWith('isAdmin='))?.split('=')[1] === 'true';

                    
    if (!isAdmin) {    
        alert('Access denied. Admin privileges required.');
        return;
    }
    
    const adminName = document.getElementById('admin-name');
    adminName.textContent = localStorage.getItem('username') || 'Admin';
    
    loadUsers();
    
    document.getElementById('refresh-btn').addEventListener('click', loadUsers);
    document.getElementById('logout-btn').addEventListener('click', logout);
    
    const editModal = document.getElementById('edit-modal');
    const closeBtn = document.querySelector('.close-btn');
    const editForm = document.getElementById('edit-form');
    const cancelEdit = document.getElementById('cancel-edit');
    
    const deleteConfirm = document.getElementById('delete-confirm');
    const confirmDelete = document.getElementById('confirm-delete');
    const cancelDelete = document.getElementById('cancel-delete');
    
    closeBtn.addEventListener('click', () => {
        editModal.style.display = 'none';
    });
    
    cancelEdit.addEventListener('click', () => {
        editModal.style.display = 'none';
    });
    
    cancelDelete.addEventListener('click', () => {
        deleteConfirm.style.display = 'none';
    });
    
    editForm.addEventListener('submit', function(event) {
        event.preventDefault();
        updateUser();
    });
    
    confirmDelete.addEventListener('click', function() {
        const userId = document.getElementById('delete-id').value;
        deleteUser(userId);
    });
    
    window.addEventListener('click', function(event) {
        if (event.target === editModal) {
            editModal.style.display = 'none';
        }
        if (event.target === deleteConfirm) {
            deleteConfirm.style.display = 'none';
        }
    });
});

async function loadUsers() {
    const usersList = document.getElementById('users-list');
    usersList.innerHTML = '<tr><td colspan="5" class="loading">Loading users...</td></tr>';
    
    try {
        const response = await fetch('http://127.0.0.1:8080/StockDashboard/AdminServlet', {
            method: 'GET',
            credentials: 'include'
        });
        
        const data = await response.json();
        
        if (data.success) {
            displayUsers(data.users);
        } else {
            usersList.innerHTML = `<tr><td colspan="5" class="error-message">${data.message || 'Failed to load users'}</td></tr>`;
        }
    } catch (error) {
        console.error('Error fetching users:', error);
        usersList.innerHTML = '<tr><td colspan="5" class="error-message">Failed to connect to server</td></tr>';
    }
}

function displayUsers(users) {
    const usersList = document.getElementById('users-list');
    usersList.innerHTML = '';
    
    if (users.length === 0) {
        usersList.innerHTML = '<tr><td colspan="5">No users found</td></tr>';
        return;
    }
    
    users.forEach(user => {
        const row = document.createElement('tr');
        
        row.innerHTML = `
            <td>${user.id}</td>
            <td>${user.name}</td>
            <td>${user.email}</td>
            <td>${formatDate(user.createdAt)}</td>
            <td class="action-buttons">
                <button class="edit-btn" data-id="${user.id}" 
                    data-name="${user.name}" data-email="${user.email}">Edit</button>
                <button class="delete-btn" data-id="${user.id}">Delete</button>
            </td>
        `;
        
        usersList.appendChild(row);
    });
    
    // Add event listeners to the new buttons
    document.querySelectorAll('.edit-btn').forEach(button => {
        button.addEventListener('click', function() {
            openEditModal(this.dataset.id, this.dataset.name, this.dataset.email);
        });
    });
    
    document.querySelectorAll('.delete-btn').forEach(button => {
        button.addEventListener('click', function() {
            openDeleteConfirm(this.dataset.id);
        });
    });
}

function formatDate(dateString) {
    if (!dateString) return 'N/A';
    
    const date = new Date(dateString);
    if (isNaN(date.getTime())) return dateString;
    
    return date.toLocaleString();
}

function openEditModal(id, name, email) {
    document.getElementById('edit-id').value = id;
    document.getElementById('edit-name').value = name;
    document.getElementById('edit-email').value = email;
    document.getElementById('edit-password').value = '';
    
    document.getElementById('edit-modal').style.display = 'flex';
}

function openDeleteConfirm(id) {
    document.getElementById('delete-id').value = id;
    document.getElementById('delete-confirm').style.display = 'flex';
}

async function updateUser() {
    const id = document.getElementById('edit-id').value;
    const name = document.getElementById('edit-name').value;
    const email = document.getElementById('edit-email').value;
    const password = document.getElementById('edit-password').value;

    console.log(id, name, email, password);
    
    try {
        const response = await fetch('http://127.0.0.1:8080/StockDashboard/AdminServlet', {
            method: 'PUT',
            credentials: 'include',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: `id=${encodeURIComponent(id)}&name=${encodeURIComponent(name)}&email=${encodeURIComponent(email)}&password=${encodeURIComponent(password)}`
        });
        
        const data = await response.json();
        console.log(data);
        
        if (data.success) {
            alert('User updated successfully');
            document.getElementById('edit-modal').style.display = 'none';
            loadUsers();
        } else {
            alert('Failed to update user: ' + (data.message || 'Unknown error'));
        }
    } catch (error) {
        console.error('Error updating user:', error);
        alert('Failed to connect to server');
    }
}

async function deleteUser(id) {
    try {
        const response = await fetch(`http://127.0.0.1:8080/StockDashboard/AdminServlet?id=${id}`, {
            method: 'DELETE',
            credentials: 'include'
        });
        
        const data = await response.json();
        
        if (data.success) {
            alert('User deleted successfully');
            document.getElementById('delete-confirm').style.display = 'none';
            loadUsers();
        } else {
            alert('Failed to delete user: ' + (data.message || 'Unknown error'));
        }
    } catch (error) {
        console.error('Error deleting user:', error);
        alert('Failed to connect to server');
    }
}

function logout() {
    localStorage.removeItem('username');
    localStorage.removeItem('email');
    localStorage.removeItem('loginTime');
    localStorage.removeItem('sessionId');
    localStorage.removeItem('isAdmin');
    
    window.location.href = 'login.html';
}