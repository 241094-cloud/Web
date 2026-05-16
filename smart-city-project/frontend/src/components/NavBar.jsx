import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { LogOut, Menu, X, Bell, User } from 'lucide-react';
import Button from './Button';

export default function NavBar({ onMenuToggle }) {
  const navigate = useNavigate();
  const user = JSON.parse(localStorage.getItem('user') || '{}');
  const [showDropdown, setShowDropdown] = useState(false);
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  const handleLogout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    navigate('/login');
  };

  return (
    <nav className="bg-white shadow-lg sticky top-0 z-40">
      <div className="max-w-7xl mx-auto px-4 py-4 flex justify-between items-center">
        <div className="flex items-center gap-4">
          <button onClick={onMenuToggle} className="lg:hidden">
            <Menu size={24} className="text-gray-700" />
          </button>
          <h1 className="text-2xl font-bold bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent">
            🏙️ Smart City
          </h1>
        </div>

        <div className="flex items-center gap-6">
          <button className="relative hover:scale-110 transition-transform">
            <Bell size={24} className="text-gray-600" />
            <span className="absolute top-0 right-0 bg-red-500 text-white text-xs rounded-full w-5 h-5 flex items-center justify-center">3</span>
          </button>

          <div className="relative">
            <button 
              onClick={() => setShowDropdown(!showDropdown)}
              className="flex items-center gap-2 hover:bg-gray-100 px-3 py-2 rounded-lg transition-colors"
            >
              <User size={20} className="text-gray-600" />
              <span className="text-gray-700 font-medium">{user.full_name || 'User'}</span>
            </button>

            {showDropdown && (
              <div className="absolute right-0 mt-2 w-48 bg-white rounded-lg shadow-xl animate-fade-in">
                <div className="p-4 border-b">
                  <p className="text-sm text-gray-600">Logged in as</p>
                  <p className="font-semibold text-gray-800">{user.email}</p>
                  <p className="text-xs text-blue-600 uppercase">{user.role}</p>
                </div>
                <button 
                  onClick={handleLogout}
                  className="w-full flex items-center gap-2 px-4 py-2 text-red-600 hover:bg-red-50 transition-colors"
                >
                  <LogOut size={18} />
                  Logout
                </button>
              </div>
            )}
          </div>
        </div>
      </div>
    </nav>
  );
}