import React, { useState } from 'react';
import { FileText, CheckCircle, Clock, AlertCircle } from 'lucide-react';
import StatCard from '../../components/StatCard.jsx';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';

export default function CitizenDashboard() {
  const [stats] = useState({
    totalComplaints: 12,
    resolved: 8,
    pending: 3,
    inProgress: 1,
  });

  const chartData = [
    { month: 'Jan', complaints: 2 },
    { month: 'Feb', complaints: 3 },
    { month: 'Mar', complaints: 2 },
    { month: 'Apr', complaints: 1 },
    { month: 'May', complaints: 2 },
    { month: 'Jun', complaints: 2 },
  ];

  return (
    <div className="p-6 space-y-8">
      <div>
        <h1 className="text-3xl font-bold text-gray-800">My Dashboard</h1>
        <p className="text-gray-600">Track your complaints and contributions</p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard 
          icon={FileText} 
          title="Total Complaints" 
          value={stats.totalComplaints}
          color="blue"
        />
        <StatCard 
          icon={CheckCircle} 
          title="Resolved" 
          value={stats.resolved}
          color="green"
        />
        <StatCard 
          icon={Clock} 
          title="In Progress" 
          value={stats.inProgress}
          color="purple"
        />
        <StatCard 
          icon={AlertCircle} 
          title="Pending" 
          value={stats.pending}
          color="red"
        />
      </div>

      {/* Activity Chart */}
      <div className="bg-white rounded-2xl shadow-lg p-6">
        <h2 className="text-xl font-bold text-gray-800 mb-6">Your Activity (Last 6 Months)</h2>
        <ResponsiveContainer width="100%" height={300}>
          <LineChart data={chartData}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="month" />
            <YAxis />
            <Tooltip />
            <Legend />
            <Line 
              type="monotone" 
              dataKey="complaints" 
              stroke="#3b82f6" 
              strokeWidth={2}
              dot={{ fill: '#3b82f6', r: 5 }}
            />
          </LineChart>
        </ResponsiveContainer>
      </div>

      {/* My Recent Complaints */}
      <div className="bg-white rounded-2xl shadow-lg p-6">
        <h2 className="text-xl font-bold text-gray-800 mb-4">My Recent Complaints</h2>
        <div className="space-y-4">
          {[...Array(4)].map((_, i) => {
            const statuses = ['Resolved', 'In Progress', 'Pending', 'Resolved'];
            const colors = ['bg-green-100 text-green-800', 'bg-blue-100 text-blue-800', 'bg-yellow-100 text-yellow-800', 'bg-green-100 text-green-800'];
            
            return (
              <div key={i} className="flex items-center justify-between p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors cursor-pointer">
                <div>
                  <p className="font-medium text-gray-800">Complaint #{5000 + i}</p>
                  <p className="text-sm text-gray-600">Street lighting issue in Area-{101 + i}</p>
                </div>
                <span className={`px-3 py-1 rounded-full text-sm font-medium ${colors[i]}`}>
                  {statuses[i]}
                </span>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}