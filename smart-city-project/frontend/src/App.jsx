import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import NavBar from './components/NavBar.jsx';
import Sidebar from './components/Sidebar.jsx';
import ProtectedRoute from './components/ProtectedRoute.jsx';
import { useState } from 'react';

// Auth Pages
import Login from './pages/Login.jsx';
import Register from './pages/Register.jsx';

// Admin Pages
import AdminDashboard from './pages/admin/AdminDashboard.jsx';

// Citizen Pages
import CitizenDashboard from './pages/citizen/CitizenDashboard.jsx';
import FileComplaint from './pages/citizen/FileComplaint.jsx';

// MainLayout component - MOVED OUTSIDE
function MainLayout({ children, sidebarOpen, setSidebarOpen }) {
  return (
    <div className="flex h-screen bg-gray-100">
      <Sidebar isOpen={sidebarOpen} onClose={() => setSidebarOpen(false)} />
      <div className="flex-1 flex flex-col overflow-hidden">
        <NavBar onMenuToggle={() => setSidebarOpen(!sidebarOpen)} />
        <main className="flex-1 overflow-auto">
          {children}
        </main>
      </div>
    </div>
  );
}

export default function App() {
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const token = localStorage.getItem('token');
  const user = JSON.parse(localStorage.getItem('user') || '{}');

  return (
    <Router>
      <Routes>
        {/* Auth Routes */}
        <Route path="/login" element={<Login />} />
        <Route path="/register" element={<Register />} />

        {/* Admin Routes */}
        <Route
          path="/admin/dashboard"
          element={
            <ProtectedRoute requiredRole="admin">
              <MainLayout sidebarOpen={sidebarOpen} setSidebarOpen={setSidebarOpen}>
                <AdminDashboard />
              </MainLayout>
            </ProtectedRoute>
          }
        />

        {/* Citizen Routes */}
        <Route
          path="/citizen/dashboard"
          element={
            <ProtectedRoute requiredRole="citizen">
              <MainLayout sidebarOpen={sidebarOpen} setSidebarOpen={setSidebarOpen}>
                <CitizenDashboard />
              </MainLayout>
            </ProtectedRoute>
          }
        />
        <Route
          path="/citizen/file-complaint"
          element={
            <ProtectedRoute requiredRole="citizen">
              <MainLayout sidebarOpen={sidebarOpen} setSidebarOpen={setSidebarOpen}>
                <FileComplaint />
              </MainLayout>
            </ProtectedRoute>
          }
        />

        {/* Default Route */}
        <Route
          path="/"
          element={
            token
              ? <Navigate to={user.role === 'admin' ? '/admin/dashboard' : '/citizen/dashboard'} />
              : <Navigate to="/login" />
          }
        />
      </Routes>
    </Router>
  );
}