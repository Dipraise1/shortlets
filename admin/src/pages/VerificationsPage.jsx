import { useState } from 'react';
import { Check, X, Phone, Mail, Building } from 'lucide-react';
import Badge from '../components/Badge';
import PageHeader from '../components/PageHeader';
import { verifications as initialVerifications } from '../data/mockData';

function timeAgo(date) {
  const diff = Date.now() - date.getTime();
  const h = Math.floor(diff / 3600000);
  const d = Math.floor(diff / 86400000);
  if (h < 1) return 'Just now';
  if (h < 24) return `${h}h ago`;
  return `${d}d ago`;
}

export default function VerificationsPage() {
  const [verifications, setVerifications] = useState(initialVerifications);
  const [filter, setFilter] = useState('all');

  const filtered = filter === 'all' ? verifications : verifications.filter(v => v.status === filter);

  const update = (id, status) => {
    setVerifications(prev => prev.map(v => v.id === id ? { ...v, status } : v));
  };

  const counts = {
    all: verifications.length,
    pending: verifications.filter(v => v.status === 'pending').length,
    approved: verifications.filter(v => v.status === 'approved').length,
    rejected: verifications.filter(v => v.status === 'rejected').length,
  };

  return (
    <div style={{ padding: '28px 28px 40px' }}>
      <PageHeader
        title="Lister Verifications"
        subtitle="Review and approve lister identity submissions"
      />

      {/* Filter tabs */}
      <div style={{ display: 'flex', gap: 6, marginBottom: 22, flexWrap: 'wrap' }}>
        {[['all', 'All'], ['pending', 'Pending'], ['approved', 'Approved'], ['rejected', 'Rejected']].map(([val, label]) => (
          <button key={val} onClick={() => setFilter(val)} style={{
            padding: '8px 16px', borderRadius: 10, border: '1px solid',
            borderColor: filter === val ? '#111' : '#e5e7eb',
            background: filter === val ? '#111' : '#fff',
            color: filter === val ? '#fff' : '#374151',
            fontSize: 13, fontWeight: 500, cursor: 'pointer',
            display: 'flex', alignItems: 'center', gap: 6,
          }}>
            {label}
            <span style={{ background: filter === val ? 'rgba(255,255,255,0.2)' : '#f3f4f6', color: filter === val ? '#fff' : '#6b7280', borderRadius: 99, padding: '0 7px', fontSize: 11, fontWeight: 700 }}>
              {counts[val]}
            </span>
          </button>
        ))}
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(340px, 1fr))', gap: 16 }}>
        {filtered.map(v => (
          <div key={v.id} style={{ background: '#fff', borderRadius: 16, padding: 20, boxShadow: '0 1px 4px rgba(0,0,0,0.06)', border: '1px solid #f3f4f6', display: 'flex', flexDirection: 'column', gap: 14 }}>
            {/* Header */}
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                <div style={{ width: 40, height: 40, borderRadius: '50%', background: '#111', display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff', fontWeight: 700, fontSize: 15 }}>
                  {v.fullName[0]}
                </div>
                <div>
                  <div style={{ fontWeight: 700, fontSize: 15, color: '#111' }}>{v.fullName}</div>
                  <div style={{ fontSize: 11, color: '#9ca3af' }}>{timeAgo(v.submittedAt)}</div>
                </div>
              </div>
              <Badge label={v.status} type={v.status} />
            </div>

            {/* Details */}
            <div style={{ background: '#f9fafb', borderRadius: 10, padding: '12px 14px', display: 'flex', flexDirection: 'column', gap: 8 }}>
              {v.businessName && (
                <div style={{ display: 'flex', alignItems: 'center', gap: 8, fontSize: 13, color: '#374151' }}>
                  <Building size={13} color="#9ca3af" />
                  {v.businessName}
                </div>
              )}
              <div style={{ display: 'flex', alignItems: 'center', gap: 8, fontSize: 13, color: '#374151' }}>
                <Mail size={13} color="#9ca3af" />
                {v.email}
              </div>
              <div style={{ display: 'flex', alignItems: 'center', gap: 8, fontSize: 13, color: '#374151' }}>
                <Phone size={13} color="#9ca3af" />
                {v.phone}
              </div>
            </div>

            {/* Actions */}
            {v.status === 'pending' && (
              <div style={{ display: 'flex', gap: 8 }}>
                <button onClick={() => update(v.id, 'rejected')} style={{ flex: 1, padding: '9px', borderRadius: 10, border: '1px solid #fee2e2', background: '#fff', color: '#ef4444', fontWeight: 600, fontSize: 13, cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 5 }}>
                  <X size={14} /> Reject
                </button>
                <button onClick={() => update(v.id, 'approved')} style={{ flex: 1, padding: '9px', borderRadius: 10, border: 'none', background: '#111', color: '#fff', fontWeight: 600, fontSize: 13, cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 5 }}>
                  <Check size={14} /> Approve
                </button>
              </div>
            )}
            {v.status !== 'pending' && (
              <button onClick={() => update(v.id, 'pending')} style={{ padding: '8px', borderRadius: 10, border: '1px solid #e5e7eb', background: '#fff', color: '#6b7280', fontWeight: 500, fontSize: 12, cursor: 'pointer' }}>
                Reset to Pending
              </button>
            )}
          </div>
        ))}
        {filtered.length === 0 && (
          <div style={{ gridColumn: '1/-1', padding: 60, textAlign: 'center', color: '#9ca3af', fontSize: 14 }}>
            No verifications in this category.
          </div>
        )}
      </div>
    </div>
  );
}
