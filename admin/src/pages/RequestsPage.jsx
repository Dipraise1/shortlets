import { useState } from 'react';
import { Check, X, MessageSquare, Calendar, Phone, Mail } from 'lucide-react';
import Badge from '../components/Badge';
import PageHeader from '../components/PageHeader';
import { requests as initialRequests } from '../data/mockData';

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

export default function RequestsPage() {
  const [requests, setRequests] = useState(initialRequests);
  const [filter, setFilter] = useState('all');

  const filtered = filter === 'all' ? requests : requests.filter(r => r.status === filter);

  const update = (id, status) => {
    setRequests(prev => prev.map(r => r.id === id ? { ...r, status } : r));
  };

  const counts = {
    all: requests.length,
    pending: requests.filter(r => r.status === 'pending').length,
    accepted: requests.filter(r => r.status === 'accepted').length,
    declined: requests.filter(r => r.status === 'declined').length,
  };

  return (
    <div style={{ padding: '28px 28px 40px' }}>
      <PageHeader
        title="Rental Requests"
        subtitle="All booking and rental requests across the platform"
      />

      {/* Filter tabs */}
      <div style={{ display: 'flex', gap: 6, marginBottom: 22, flexWrap: 'wrap' }}>
        {[['all', 'All'], ['pending', 'Pending'], ['accepted', 'Accepted'], ['declined', 'Declined']].map(([val, label]) => (
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

      <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
        {filtered.map(r => (
          <div key={r.id} style={{ background: '#fff', borderRadius: 16, padding: 20, boxShadow: '0 1px 4px rgba(0,0,0,0.06)', border: '1px solid #f3f4f6' }}>
            {/* Header row */}
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 14, flexWrap: 'wrap', gap: 8 }}>
              <div>
                <div style={{ fontWeight: 700, fontSize: 15, color: '#111' }}>{r.propertyName}</div>
                <div style={{ fontSize: 12, color: '#9ca3af', marginTop: 2 }}>{timeAgo(r.createdAt)}</div>
              </div>
              <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                <span style={{ fontWeight: 700, fontSize: 16, color: '#111' }}>{formatNaira(r.totalPrice)}</span>
                <Badge label={r.status} type={r.status} />
              </div>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: 10, marginBottom: 14 }}>
              {/* Renter */}
              <div style={{ background: '#f9fafb', borderRadius: 10, padding: '12px 14px' }}>
                <div style={{ fontSize: 11, fontWeight: 600, color: '#9ca3af', textTransform: 'uppercase', letterSpacing: '0.5px', marginBottom: 8 }}>Renter</div>
                <div style={{ fontWeight: 600, fontSize: 14, color: '#111', marginBottom: 6 }}>{r.renterName}</div>
                <div style={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 6, fontSize: 12, color: '#6b7280' }}>
                    <Mail size={12} color="#9ca3af" /> {r.renterEmail}
                  </div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 6, fontSize: 12, color: '#6b7280' }}>
                    <Phone size={12} color="#9ca3af" /> {r.renterPhone}
                  </div>
                </div>
              </div>

              {/* Dates */}
              <div style={{ background: '#f9fafb', borderRadius: 10, padding: '12px 14px' }}>
                <div style={{ fontSize: 11, fontWeight: 600, color: '#9ca3af', textTransform: 'uppercase', letterSpacing: '0.5px', marginBottom: 8 }}>Dates</div>
                <div style={{ display: 'flex', alignItems: 'flex-start', gap: 6, fontSize: 13, color: '#374151' }}>
                  <Calendar size={13} color="#9ca3af" style={{ marginTop: 1, flexShrink: 0 }} />
                  <span>{r.dateInfo}</span>
                </div>
              </div>

              {/* Message */}
              {r.message && (
                <div style={{ background: '#f9fafb', borderRadius: 10, padding: '12px 14px' }}>
                  <div style={{ fontSize: 11, fontWeight: 600, color: '#9ca3af', textTransform: 'uppercase', letterSpacing: '0.5px', marginBottom: 8 }}>Message</div>
                  <div style={{ display: 'flex', gap: 6, fontSize: 13, color: '#374151' }}>
                    <MessageSquare size={13} color="#9ca3af" style={{ marginTop: 1, flexShrink: 0 }} />
                    <span style={{ lineHeight: 1.5 }}>{r.message}</span>
                  </div>
                </div>
              )}
            </div>

            {/* Actions */}
            {r.status === 'pending' && (
              <div style={{ display: 'flex', gap: 8 }}>
                <button onClick={() => update(r.id, 'declined')} style={{ padding: '9px 18px', borderRadius: 10, border: '1px solid #fee2e2', background: '#fff', color: '#ef4444', fontWeight: 600, fontSize: 13, cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 5 }}>
                  <X size={14} /> Decline
                </button>
                <button onClick={() => update(r.id, 'accepted')} style={{ padding: '9px 18px', borderRadius: 10, border: 'none', background: '#111', color: '#fff', fontWeight: 600, fontSize: 13, cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 5 }}>
                  <Check size={14} /> Accept
                </button>
              </div>
            )}
            {r.status !== 'pending' && (
              <button onClick={() => update(r.id, 'pending')} style={{ padding: '8px 14px', borderRadius: 10, border: '1px solid #e5e7eb', background: '#fff', color: '#6b7280', fontWeight: 500, fontSize: 12, cursor: 'pointer' }}>
                Reset to Pending
              </button>
            )}
          </div>
        ))}
        {filtered.length === 0 && (
          <div style={{ padding: 60, textAlign: 'center', color: '#9ca3af', fontSize: 14, background: '#fff', borderRadius: 16 }}>
            No requests in this category.
          </div>
        )}
      </div>
    </div>
  );
}
