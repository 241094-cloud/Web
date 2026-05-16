import React, { useState, useEffect } from 'react';
import { BarChart3, AlertCircle, Users, FileText } from 'lucide-react';
import StatCard from '../../components/StatCard.jsx';
import DashboardCharts from '../../components/charts/DashboardCharts.jsx';

export default function AdminDashboard() {
  const [stats, setStats] = useState({
    totalComplaints: 156,
    resolvedComplaints: 98,
    pendingComplaints: 58,
    totalUsers: 1204,
    activeUsers: 892,
  });

  return (
    <div className="p-6 space-y-8">
      <div>
        <h1 className="text-3xl font-bold text-gray-800 mb-2">Dashboard</h1>
        <p className="text-gray-600">Welcome back, Admin! Here's your performance overview</p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-6">
        <StatCard 
          icon={FileText} 
          title="Total Complaints" 
          value={stats.totalComplaints} 
          trend={12}
          color="blue"
        />
        <StatCard 
          icon={AlertCircle} 
          title="Pending" 
          value={stats.pendingComplaints} 
          trend={-5}
          color="red"
        />
        <StatCard 
          icon={BarChart3} 
          title="Resolved" 
          value={stats.resolvedComplaints} 
          trend={8}
          color="green"
        />
        <StatCard 
          icon={Users} 
          title="Total Users" 
          value={stats.totalUsers} 
          trend={15}
          color="purple"
        />
        <StatCard 
          icon={Users} 
          title="Active Users" 
          value={stats.activeUsers} 
          trend={6}
          color="blue"
        />
      </div>

      {/* Charts Section */}
      <div className="bg-white rounded-2xl shadow-lg p-6">
        <h2 className="text-xl font-bold text-gray-800 mb-6">Analytics Overview</h2>
        <DashboardCharts />
      </div>

      {/* Recent Activity */}
      <div className="bg-white rounded-2xl shadow-lg p-6">
        <h2 className="text-xl font-bold text-gray-800 mb-4">Recent Complaints</h2>
        <div className="space-y-4">
          {[...Array(5)].map((_, i) => (
            <div key={i} className="flex items-center justify-between p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors">
              <div>
                <p className="font-medium text-gray-800">Complaint #{1000 + i}</p>
                <p className="text-sm text-gray-600">Road repair needed at Main Street</p>
              </div>
              <span className="px-3 py-1 bg-yellow-100 text-yellow-800 rounded-full text-sm font-medium">Pending</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}