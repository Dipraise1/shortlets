export default function StatCard({ label, value, sub, icon: Icon, color = '#111', bg = '#f9fafb', trend }) {
  return (
    <div style={{
      background: '#fff',
      borderRadius: 16,
      padding: '20px 22px',
      boxShadow: '0 1px 4px rgba(0,0,0,0.06)',
      display: 'flex',
      flexDirection: 'column',
      gap: 12,
      border: '1px solid #f3f4f6',
    }}>
      <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between' }}>
        <div>
          <div style={{ fontSize: 12, fontWeight: 500, color: '#9ca3af', marginBottom: 6, textTransform: 'uppercase', letterSpacing: '0.5px' }}>{label}</div>
          <div style={{ fontSize: 28, fontWeight: 700, color: '#111', letterSpacing: '-0.5px', lineHeight: 1 }}>{value}</div>
          {sub && <div style={{ fontSize: 12, color: '#9ca3af', marginTop: 6 }}>{sub}</div>}
        </div>
        {Icon && (
          <div style={{ width: 42, height: 42, borderRadius: 12, background: bg, display: 'flex', alignItems: 'center', justifyContent: 'center', color, flexShrink: 0 }}>
            <Icon size={20} strokeWidth={2} />
          </div>
        )}
      </div>
      {trend !== undefined && (
        <div style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
          <span style={{ fontSize: 12, fontWeight: 600, color: trend >= 0 ? '#10b981' : '#ef4444' }}>
            {trend >= 0 ? '↑' : '↓'} {Math.abs(trend)}%
          </span>
          <span style={{ fontSize: 12, color: '#9ca3af' }}>vs last month</span>
        </div>
      )}
    </div>
  );
}
