import React from 'react';
import { Link, useLocation } from 'react-router-dom';
import { LayoutDashboard, FileText, Users, Settings, BarChart3, Plus, MessageSquare, X } from 'lucide-react';

export default function Sidebar({ isOpen, onClose }) {
  const user = JSON.parse(localStorage.getItem('user') || '{}');
  const location = useLocation();

  const adminMenus = [
    { icon: LayoutDashboard, label: 'Dashboard', path: '/admin/dashboard' },
    { icon: FileText, label: 'Complaints', path: '/admin/complaints' },
    { icon: Users, label: 'Users', path: '/admin/users' },
    { icon: BarChart3, label: 'Analytics', path: '/admin/analytics' },
    { icon: Settings, label: 'Settings', path: '/admin/settings' },
  ];

  const citizenMenus = [
    { icon: LayoutDashboard, label: 'Dashboard', path: '/citizen/dashboard' },
    { icon: Plus, label: 'File Complaint', path: '/citizen/file-complaint' },
    { icon: FileText, label: 'My Complaints', path: '/citizen/my-complaints' },
    { icon: MessageSquare, label: 'Community', path: '/citizen/community' },
  ];

  const menus = user.role === 'admin' ? adminMenus : citizenMenus;

  const isActive = (path) => location.pathname === path;

  return (
    <>
      {isOpen && <div className="fixed inset-0 bg-black/50 lg:hidden z-30" onClick={onClose} />}
      
      <div className={`fixed lg:sticky left-0 top-0 h-screen w-64 bg-gradient-to-b from-gray-900 to-gray-800 text-white transition-transform duration-300 z-40 ${isOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'}`}>
        <div className="p-6 border-b border-gray-700 flex justify-between items-center">
          <h2 className="text-xl font-bold">{user.role === 'admin' ? '👨‍💼 Admin' : '👤 Citizen'}</h2>
          <button onClick={onClose} className="lg:hidden">
            <X size={24} />
          </button>
        </div>

        <nav className="mt-8 space-y-2 px-4">
          {menus.map((menu) => {
            const Icon = menu.icon;
            return (
              <Link
                key={menu.path}
                to={menu.path}
                onClick={onClose}
                className={`flex items-center gap-3 px-4 py-3 rounded-lg transition-all duration-300 ${
                  isActive(menu.path)
                    ? 'bg-gradient-to-r from-blue-500 to-blue-600 shadow-lg'
                    : 'hover:bg-gray-700'
                }`}
              >
                <Icon size={20} />
                <span className="font-medium">{menu.label}</span>
              </Link>
            );
          })}
        </nav>

        <div className="absolute bottom-6 left-4 right-4 bg-gray-700 rounded-lg p-4">
          <p className="text-sm text-gray-300">Need help?</p>
          <button className="mt-2 w-full bg-blue-600 hover:bg-blue-700 text-white py-2 rounded-lg font-medium transition-colors">
            Contact Support
          </button>
        </div>
      </div>
    </>
  );
}