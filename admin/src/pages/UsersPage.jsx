import { useState } from 'react';
import { Search, UserX, UserCheck } from 'lucide-react';
import Badge from '../components/Badge';
import PageHeader from '../components/PageHeader';
import { users as initialUsers } from '../data/mockData';

function timeAgo(date) {
  const d = Math.floor((Date.now() - date.getTime()) / 86400000);
  return d === 0 ? 'Today' : d === 1 ? 'Yesterday' : `${d} days ago`;
}

export default function UsersPage() {
  const [users, setUsers] = useState(initialUsers);
  const [search, setSearch] = useState('');
  const [roleFilter, setRoleFilter] = useState('All');
  const [statusFilter, setStatusFilter] = useState('All');

  const filtered = users.filter(u => {
    const q = search.toLowerCase();
    const matchSearch = !q || u.name.toLowerCase().includes(q) || u.email.toLowerCase().includes(q);
    const matchRole = roleFilter === 'All' || u.role === roleFilter;
    const matchStatus = statusFilter === 'All' || u.status === statusFilter;
    return matchSearch && matchRole && matchStatus;
  });

  const toggleStatus = (id) => {
    setUsers(prev => prev.map(u => u.id === id
      ? { ...u, status: u.status === 'active' ? 'suspended' : 'active' }
      : u
    ));
  };

  return (
    <div style={{ padding: '28px 28px 40px' }}>
      <PageHeader
        title="Users"
        subtitle={`${users.length} total · ${users.filter(u => u.role === 'lister').length} listers · ${users.filter(u => u.status === 'suspended').length} suspended`}
      />

      {/* Filters */}
      <div style={{ display: 'flex', gap: 10, flexWrap: 'wrap', marginBottom: 20 }}>
        <div style={{ position: 'relative', flex: '1 1 220px' }}>
          <Search size={15} style={{ position: 'absolute', left: 12, top: '50%', transform: 'translateY(-50%)', color: '#9ca3af' }} />
          <input
            value={search}
            onChange={e => setSearch(e.target.value)}
            placeholder="Search by name or email..."
            style={{ width: '100%', padding: '9px 12px 9px 34px', borderRadius: 10, border: '1px solid #e5e7eb', fontSize: 13, outline: 'none', background: '#fff', boxSizing: 'border-box' }}
          />
        </div>
        {['All', 'renter', 'lister'].map(r => (
          <button key={r} onClick={() => setRoleFilter(r)} style={{ padding: '8px 14px', borderRadius: 10, border: '1px solid', borderColor: roleFilter === r ? '#111' : '#e5e7eb', background: roleFilter === r ? '#111' : '#fff', color: roleFilter === r ? '#fff' : '#374151', fontSize: 13, fontWeight: 500, cursor: 'pointer', textTransform: 'capitalize' }}>
            {r === 'All' ? 'All Roles' : r === 'renter' ? 'Renters' : 'Listers'}
          </button>
        ))}
        {['All', 'active', 'suspended'].map(s => (
          <button key={s} onClick={() => setStatusFilter(s)} style={{ padding: '8px 14px', borderRadius: 10, border: '1px solid', borderColor: statusFilter === s ? '#111' : '#e5e7eb', background: statusFilter === s ? '#111' : '#fff', color: statusFilter === s ? '#fff' : '#374151', fontSize: 13, fontWeight: 500, cursor: 'pointer', textTransform: 'capitalize' }}>
            {s === 'All' ? 'All Status' : s}
          </button>
        ))}
      </div>

      {/* Table */}
      <div style={{ background: '#fff', borderRadius: 16, boxShadow: '0 1px 4px rgba(0,0,0,0.06)', border: '1px solid #f3f4f6', overflow: 'hidden' }}>
        <div style={{ overflowX: 'auto' }}>
          <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 13 }}>
            <thead>
              <tr style={{ borderBottom: '1px solid #f3f4f6' }}>
                {['User', 'Email', 'Role', 'Bookings', 'Joined', 'Status', 'Action'].map(h => (
                  <th key={h} style={{ padding: '12px 16px', textAlign: 'left', fontWeight: 600, color: '#6b7280', fontSize: 11, textTransform: 'uppercase', letterSpacing: '0.5px', whiteSpace: 'nowrap' }}>{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {filtered.map((u, i) => (
                <tr key={u.id} style={{ borderBottom: i < filtered.length - 1 ? '1px solid #f9fafb' : 'none' }}
                  onMouseEnter={e => e.currentTarget.style.background = '#fafafa'}
                  onMouseLeave={e => e.currentTarget.style.background = 'transparent'}
                >
                  <td style={{ padding: '12px 16px' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                      <div style={{ width: 34, height: 34, borderRadius: '50%', background: '#111', display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff', fontWeight: 700, fontSize: 13, flexShrink: 0 }}>
                        {u.name[0]}
                      </div>
                      <span style={{ fontWeight: 600, color: '#111' }}>{u.name}</span>
                    </div>
                  </td>
                  <td style={{ padding: '12px 16px', color: '#6b7280' }}>{u.email}</td>
                  <td style={{ padding: '12px 16px' }}><Badge label={u.role} type={u.role} /></td>
                  <td style={{ padding: '12px 16px', color: '#374151', textAlign: 'center' }}>{u.bookingsCount}</td>
                  <td style={{ padding: '12px 16px', color: '#6b7280', whiteSpace: 'nowrap' }}>{timeAgo(u.joinedAt)}</td>
                  <td style={{ padding: '12px 16px' }}><Badge label={u.status} type={u.status} /></td>
                  <td style={{ padding: '12px 16px' }}>
                    <button
                      onClick={() => toggleStatus(u.id)}
                      title={u.status === 'active' ? 'Suspend user' : 'Reactivate user'}
                      style={{
                        padding: '6px 12px',
                        borderRadius: 8,
                        border: '1px solid',
                        borderColor: u.status === 'active' ? '#fee2e2' : '#dcfce7',
                        background: '#fff',
                        cursor: 'pointer',
                        display: 'flex',
                        alignItems: 'center',
                        gap: 5,
                        fontSize: 12,
                        fontWeight: 500,
                        color: u.status === 'active' ? '#ef4444' : '#10b981',
                      }}>
                      {u.status === 'active' ? <><UserX size={13} /> Suspend</> : <><UserCheck size={13} /> Activate</>}
                    </button>
                  </td>
                </tr>
              ))}
              {filtered.length === 0 && (
                <tr><td colSpan={7} style={{ padding: 40, textAlign: 'center', color: '#9ca3af', fontSize: 14 }}>No users match your filters.</td></tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
