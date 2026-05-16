import React from 'react';
import { TrendingUp } from 'lucide-react';

export default function StatCard({ icon: Icon, title, value, trend, color = 'blue' }) {
  const bgColors = {
    blue: 'from-blue-400 to-blue-600',
    purple: 'from-purple-400 to-purple-600',
    green: 'from-green-400 to-green-600',
    red: 'from-red-400 to-red-600',
  };

  return (
    <div className="animate-fade-in bg-white rounded-2xl p-6 shadow-lg hover:shadow-2xl transition-all duration-300 border-l-4 border-blue-500">
      <div className="flex justify-between items-start">
        <div>
          <p className="text-gray-600 text-sm font-medium mb-2">{title}</p>
          <h3 className="text-3xl font-bold text-gray-800 mb-2">{value}</h3>
          {trend && (
            <div className="flex items-center gap-1 text-green-500 text-sm">
              <TrendingUp size={16} />
              <span>{trend}% increase</span>
            </div>
          )}
        </div>
        <div className={`bg-gradient-to-br ${bgColors[color]} p-3 rounded-full`}>
          <Icon size={28} className="text-white" />
        </div>
      </div>
    </div>
  );
}