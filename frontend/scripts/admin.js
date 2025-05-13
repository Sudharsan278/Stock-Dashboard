document.addEventListener('DOMContentLoaded', function() {
    const isAdmin = localStorage.getItem('isAdmin') === 'true' || 
                    document.cookie.split('; ').find(row => row.startsWith('isAdmin='))?.split('=')[1] === 'true';

    if (!isAdmin) {    
        alert('Access denied. Admin privileges required.');
        window.location.href = 'login.html';
        return;
    }
    
    const adminName = document.getElementById('admin-name');
    adminName.textContent = localStorage.getItem('username') || 'Admin';
    
    const usersCard = document.getElementById('users-card');
    const queriesCard = document.getElementById('queries-card');
    const usersData = document.getElementById('users-data');
    const queriesData = document.getElementById('queries-data');
    
    usersCard.addEventListener('click', function() {
        usersCard.classList.add('active');
        queriesCard.classList.remove('active');
        usersData.style.display = 'block';
        queriesData.style.display = 'none';
        loadUsers();
    });
    
    queriesCard.addEventListener('click', function() {
        queriesCard.classList.add('active');
        usersCard.classList.remove('active');
        queriesData.style.display = 'block';
        usersData.style.display = 'none';
        loadQueries();
    });
    
    usersCard.click();
    
    document.getElementById('refresh-users-btn').addEventListener('click', loadUsers);
    document.getElementById('refresh-queries-btn').addEventListener('click', loadQueries);
    document.getElementById('logout-btn').addEventListener('click', logout);
    
    const editModal = document.getElementById('edit-modal');
    const closeEditBtn = editModal.querySelector('.close-btn');
    const editForm = document.getElementById('edit-form');
    const cancelEdit = document.getElementById('cancel-edit');
    
    const deleteConfirm = document.getElementById('delete-confirm');
    const closeDeleteBtn = deleteConfirm.querySelector('.close-btn');
    const confirmDelete = document.getElementById('confirm-delete');
    const cancelDelete = document.getElementById('cancel-delete');
    
    
    closeEditBtn.addEventListener('click', () => {
        editModal.style.display = 'none';
    });
    
    cancelEdit.addEventListener('click', () => {
        editModal.style.display = 'none';
    });
    
    closeDeleteBtn.addEventListener('click', () => {
        deleteConfirm.style.display = 'none';
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
        
        console.log(response);
        const data = await response.json();
        console.log(data);
        
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
                <button class="action-btn edit-btn" data-id="${user.id}" 
                    data-name="${user.name}" data-email="${user.email}">
                    <i class="fas fa-edit"></i> Edit
                </button>
                <button class="action-btn delete-btn" data-id="${user.id}">
                    <i class="fas fa-trash-alt"></i> Delete
                </button>
            </td>
        `;
        
        usersList.appendChild(row);
    });
    
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

async function loadQueries() {
    const queriesList = document.getElementById('queries-list');
    queriesList.innerHTML = '<tr><td colspan="5" class="loading">Loading queries...</td></tr>';
    
    try {
        const response = await fetch('http://127.0.0.1:8080/StockDashboard/QueryServlet', {
            method: 'GET',
            credentials: 'include'
        });
        
        const data = await response.json();
        
        if (data.success) {
            displayQueries(data.queries);
        } else {
            queriesList.innerHTML = `<tr><td colspan="5" class="error-message">${data.message || 'Failed to load queries'}</td></tr>`;
        }
    } catch (error) {
        console.error('Error fetching queries:', error);
    }
}

function displayQueries(queries) {
    const queriesList = document.getElementById('queries-list');
    queriesList.innerHTML = '';
    
    if (queries.length === 0) {
        queriesList.innerHTML = '<tr><td colspan="5">No queries found</td></tr>';
        return;
    }
    
    queries.forEach(query => {
        const row = document.createElement('tr');
        
        row.innerHTML = `
            <td>${query.id}</td>
            <td>${query.name}</td>
            <td>${query.email}</td>
            <td>${query.message}</td>
            <td>${formatDate(query.createdAt)}</td>
        `;
        
        queriesList.appendChild(row);
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
    
    document.cookie = 'isAdmin=; Path=/; Expires=Thu, 01 Jan 1970 00:00:01 GMT;';
    document.cookie = 'sessionId=; Path=/; Expires=Thu, 01 Jan 1970 00:00:01 GMT;';
    
    window.location.href = 'login.html';
}