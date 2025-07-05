// src/App.js
import React, { useEffect, useState } from "react";
import axios from "axios";

const API_URL = "http://localhost:5000/api/users";

function App() {
  const [users, setUsers] = useState([]);
  const [formData, setFormData] = useState({ name: "", email: "" });
  const [editId, setEditId] = useState(null);

  // Fetch users on load
  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    const res = await axios.get(API_URL);
    setUsers(res.data);
  };

  const handleChange = (e) => {
    
    setFormData((prev) => ({ ...prev, [e.target.name]: e.target.value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (editId) {
      await axios.put(`${API_URL}/${editId}`, formData);
    } else {
      await axios.post(API_URL, formData);
    }
    setFormData({ name: "", email: "" });
    setEditId(null);
    fetchUsers();
  };

  const handleEdit = (user) => {
    
    setFormData({ name: user.name, email: user.email });
    setEditId(user._id);
  };

  const handleDelete = async (id) => {
    if (window.confirm("Are you sure you want to delete this user?")) {
      await axios.delete(`${API_URL}/${id}`);
      fetchUsers();
    }
  };

  return (
    <div style={{ maxWidth: "600px", margin: "50px auto" }}>
      <h2>User Management system</h2>

      {/* Form */}
      <form onSubmit={handleSubmit}>
        <input
          name="name"
          placeholder="Name"
          value={formData.name}
          onChange={handleChange}
          required
          style={{ padding: "10px", margin: "5px", width: "100%" }}
        />
        <input
          name="email"
          placeholder="Email"
          value={formData.email}
          onChange={handleChange}
          required
          style={{ padding: "10px", margin: "5px", width: "100%" }}
        />
        <button type="submit" style={{ padding: "10px", margin: "5px" }}>
          {editId ? "Update User" : "Add User"}
        </button>
      </form>

      {/* User List */}
      <ul style={{ listStyle: "none", padding: 0 }}>
        {users.map((user) => (
          <li key={user._id} style={{ marginBottom: "10px" }}>
            <strong>{user.name}</strong> – {user.email}
            <div>
              <button
                onClick={() => handleEdit(user)}
                style={{ marginRight: "10px" }}
              >
                Edit
              </button>
              <button onClick={() => handleDelete(user._id)}>Delete</button>
            </div>
          </li>
        ))}
      </ul>
    </div>
  );
}

export default App;
