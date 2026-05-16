import React from 'react';
import {
  LineChart, Line, BarChart, Bar, PieChart, Pie, Cell,
  XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer
} from 'recharts';

const lineData = [
  { month: 'Jan', complaints: 45, resolved: 30 },
  { month: 'Feb', complaints: 52, resolved: 38 },
  { month: 'Mar', complaints: 48, resolved: 35 },
  { month: 'Apr', complaints: 61, resolved: 48 },
  { month: 'May', complaints: 55, resolved: 42 },
  { month: 'Jun', complaints: 67, resolved: 56 },
];

const categoryData = [
  { name: 'Infrastructure', value: 35 },
  { name: 'Sanitation', value: 25 },
  { name: 'Water', value: 20 },
  { name: 'Electricity', value: 15 },
  { name: 'Other', value: 5 },
];

const COLORS = ['#3b82f6', '#8b5cf6', '#ec4899', '#f59e0b', '#06b6d4'];

export default function DashboardCharts() {
  return (
    <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
      {/* Line Chart */}
      <div>
        <h3 className="text-lg font-semibold text-gray-800 mb-4">Complaints Trend</h3>
        <ResponsiveContainer width="100%" height={300}>
          <LineChart data={lineData}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="month" />
            <YAxis />
            <Tooltip />
            <Legend />
            <Line type="monotone" dataKey="complaints" stroke="#3b82f6" strokeWidth={2} />
            <Line type="monotone" dataKey="resolved" stroke="#10b981" strokeWidth={2} />
          </LineChart>
        </ResponsiveContainer>
      </div>

      {/* Pie Chart */}
      <div>
        <h3 className="text-lg font-semibold text-gray-800 mb-4">Complaints by Category</h3>
        <ResponsiveContainer width="100%" height={300}>
          <PieChart>
            <Pie
              data={categoryData}
              cx="50%"
              cy="50%"
              labelLine={false}
              label={({ name, value }) => `${name}: ${value}%`}
              outerRadius={80}
              fill="#8884d8"
              dataKey="value"
            >
              {categoryData.map((entry, index) => (
                <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
              ))}
            </Pie>
            <Tooltip />
          </PieChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}