import { Building2, Users, ShieldCheck, FileText, TrendingUp, Clock } from 'lucide-react';
import StatCard from '../components/StatCard';
import Badge from '../components/Badge';
import PageHeader from '../components/PageHeader';
import { stats, properties, requests, verifications, users } from '../data/mockData';

function formatNaira(n) {
  return '₦' + n.toLocaleString('en-NG');
}

function timeAgo(date) {
  const diff = Date.now() - date.getTime();
  const h = Math.floor(diff / 3600000);
  const d = Math.floor(diff / 86400000);
  if (h < 1) return 'Just now';
  if (h < 24) return `${h}h ago`;
  return `${d}d ago`;
}

const recentActivity = [
  ...requests.map(r => ({ type: 'request', label: `New rental request: ${r.propertyName}`, sub: r.renterName, time: r.createdAt, status: r.status })),
  ...verifications.filter(v => v.status === 'pending').map(v => ({ type: 'verification', label: `Lister verification: ${v.fullName}`, sub: v.businessName || v.email, time: v.submittedAt, status: 'pending' })),
].sort((a, b) => b.time - a.time).slice(0, 6);

const cityBreakdown = [
  { city: 'Abuja', count: properties.filter(p => p.city === 'Abuja').length },
  { city: 'Lagos', count: properties.filter(p => p.city === 'Lagos').length },
  { city: 'Port Harcourt', count: properties.filter(p => p.city === 'Port Harcourt').length },
];
const maxCity = Math.max(...cityBreakdown.map(c => c.count));

export default function OverviewPage() {
  return (
    <div style={{ padding: '28px 28px 40px' }}>
      <PageHeader
        title="Dashboard Overview"
        subtitle="Welcome back, Admin — here's what's happening on Rosera today."
      />

      {/* Stat cards */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: 16, marginBottom: 28 }}>
        <StatCard label="Total Properties" value={stats.totalProperties} sub={`${stats.activeProperties} active`} icon={Building2} bg="#f0f9ff" color="#0ea5e9" trend={12} />
        <StatCard label="Total Users" value={stats.totalUsers} sub={`${stats.totalListers} listers`} icon={Users} bg="#faf5ff" color="#8b5cf6" trend={8} />
        <StatCard label="Pending Verifications" value={stats.pendingVerifications} sub="Needs review" icon={ShieldCheck} bg="#fffbeb" color="#f59e0b" />
        <StatCard label="Pending Requests" value={stats.pendingRequests} sub={`${stats.totalRequests} total`} icon={FileText} bg="#fef2f2" color="#ef4444" />
        <StatCard label="Total Revenue" value={formatNaira(stats.totalRevenue)} sub="From accepted bookings" icon={TrendingUp} bg="#ecfdf5" color="#10b981" trend={22} />
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: 20 }}>
        {/* Recent activity */}
        <div style={{ background: '#fff', borderRadius: 16, padding: 22, boxShadow: '0 1px 4px rgba(0,0,0,0.06)', border: '1px solid #f3f4f6' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 18 }}>
            <Clock size={16} color="#9ca3af" />
            <span style={{ fontWeight: 600, fontSize: 14, color: '#111' }}>Recent Activity</span>
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
            {recentActivity.map((item, i) => (
              <div key={i} style={{ display: 'flex', alignItems: 'flex-start', gap: 12 }}>
                <div style={{ width: 8, height: 8, borderRadius: '50%', background: item.status === 'pending' ? '#f59e0b' : item.status === 'accepted' || item.status === 'approved' ? '#10b981' : '#3b82f6', marginTop: 5, flexShrink: 0 }} />
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontSize: 13, fontWeight: 500, color: '#111', lineHeight: 1.4 }}>{item.label}</div>
                  <div style={{ fontSize: 11, color: '#9ca3af', marginTop: 2 }}>{item.sub} · {timeAgo(item.time)}</div>
                </div>
                <Badge label={item.status} type={item.status} />
              </div>
            ))}
          </div>
        </div>

        {/* City breakdown */}
        <div style={{ background: '#fff', borderRadius: 16, padding: 22, boxShadow: '0 1px 4px rgba(0,0,0,0.06)', border: '1px solid #f3f4f6' }}>
          <div style={{ fontWeight: 600, fontSize: 14, color: '#111', marginBottom: 18 }}>Properties by City</div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
            {cityBreakdown.map(({ city, count }) => (
              <div key={city}>
                <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 6 }}>
                  <span style={{ fontSize: 13, fontWeight: 500, color: '#374151' }}>{city}</span>
                  <span style={{ fontSize: 13, fontWeight: 600, color: '#111' }}>{count}</span>
                </div>
                <div style={{ height: 7, background: '#f3f4f6', borderRadius: 99, overflow: 'hidden' }}>
                  <div style={{ height: '100%', background: '#111', borderRadius: 99, width: `${(count / maxCity) * 100}%`, transition: 'width 0.4s ease' }} />
                </div>
              </div>
            ))}
          </div>

          {/* Quick stats */}
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10, marginTop: 22, paddingTop: 18, borderTop: '1px solid #f3f4f6' }}>
            {[
              { label: 'Shortlets', value: properties.filter(p => p.listingType === 'shortlet').length },
              { label: 'For Rent', value: properties.filter(p => p.listingType === 'rent').length },
              { label: 'Apartments', value: properties.filter(p => p.propertyType === 'apartment').length },
              { label: 'Houses', value: properties.filter(p => p.propertyType === 'house').length },
            ].map(({ label, value }) => (
              <div key={label} style={{ background: '#f9fafb', borderRadius: 10, padding: '12px 14px' }}>
                <div style={{ fontSize: 20, fontWeight: 700, color: '#111' }}>{value}</div>
                <div style={{ fontSize: 11, color: '#9ca3af', marginTop: 2 }}>{label}</div>
              </div>
            ))}
          </div>
        </div>

        {/* Recent users */}
        <div style={{ background: '#fff', borderRadius: 16, padding: 22, boxShadow: '0 1px 4px rgba(0,0,0,0.06)', border: '1px solid #f3f4f6' }}>
          <div style={{ fontWeight: 600, fontSize: 14, color: '#111', marginBottom: 18 }}>Recent Users</div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            {[...users].sort((a, b) => b.joinedAt - a.joinedAt).slice(0, 5).map(user => (
              <div key={user.id} style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                <div style={{ width: 34, height: 34, borderRadius: '50%', background: '#111', display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff', fontWeight: 700, fontSize: 13, flexShrink: 0 }}>
                  {user.name[0]}
                </div>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontSize: 13, fontWeight: 600, color: '#111', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{user.name}</div>
                  <div style={{ fontSize: 11, color: '#9ca3af' }}>{timeAgo(user.joinedAt)}</div>
                </div>
                <Badge label={user.role} type={user.role} />
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
