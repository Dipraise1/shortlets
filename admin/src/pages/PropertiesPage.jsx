import { useState } from 'react';
import { Search, Eye, Pause, Play, Trash2 } from 'lucide-react';
import Badge from '../components/Badge';
import PageHeader from '../components/PageHeader';
import { properties as initialProperties } from '../data/mockData';

function formatNaira(n) {
  return '₦' + n.toLocaleString('en-NG');
}

export default function PropertiesPage() {
  const [properties, setProperties] = useState(initialProperties);
  const [search, setSearch] = useState('');
  const [cityFilter, setCityFilter] = useState('All');
  const [typeFilter, setTypeFilter] = useState('All');

  const cities = ['All', ...new Set(properties.map(p => p.city))];
  const types = ['All', 'shortlet', 'rent'];

  const filtered = properties.filter(p => {
    const q = search.toLowerCase();
    const matchSearch = !q || p.name.toLowerCase().includes(q) || p.location.toLowerCase().includes(q);
    const matchCity = cityFilter === 'All' || p.city === cityFilter;
    const matchType = typeFilter === 'All' || p.listingType === typeFilter;
    return matchSearch && matchCity && matchType;
  });

  const toggleActive = (id) => {
    setProperties(prev => prev.map(p => p.id === id ? { ...p, isActive: !p.isActive } : p));
  };

  const deleteProperty = (id) => {
    if (window.confirm('Remove this property permanently?')) {
      setProperties(prev => prev.filter(p => p.id !== id));
    }
  };

  return (
    <div style={{ padding: '28px 28px 40px' }}>
      <PageHeader
        title="Properties"
        subtitle={`${properties.length} total · ${properties.filter(p => p.isActive).length} active`}
      />

      {/* Filters */}
      <div style={{ display: 'flex', gap: 10, flexWrap: 'wrap', marginBottom: 20 }}>
        <div style={{ position: 'relative', flex: '1 1 220px' }}>
          <Search size={15} style={{ position: 'absolute', left: 12, top: '50%', transform: 'translateY(-50%)', color: '#9ca3af' }} />
          <input
            value={search}
            onChange={e => setSearch(e.target.value)}
            placeholder="Search properties..."
            style={{ width: '100%', padding: '9px 12px 9px 34px', borderRadius: 10, border: '1px solid #e5e7eb', fontSize: 13, outline: 'none', background: '#fff', boxSizing: 'border-box' }}
          />
        </div>
        {cities.map(c => (
          <button key={c} onClick={() => setCityFilter(c)} style={{ padding: '8px 14px', borderRadius: 10, border: '1px solid', borderColor: cityFilter === c ? '#111' : '#e5e7eb', background: cityFilter === c ? '#111' : '#fff', color: cityFilter === c ? '#fff' : '#374151', fontSize: 13, fontWeight: 500, cursor: 'pointer' }}>{c}</button>
        ))}
        {types.map(t => (
          <button key={t} onClick={() => setTypeFilter(t)} style={{ padding: '8px 14px', borderRadius: 10, border: '1px solid', borderColor: typeFilter === t ? '#111' : '#e5e7eb', background: typeFilter === t ? '#111' : '#fff', color: typeFilter === t ? '#fff' : '#374151', fontSize: 13, fontWeight: 500, cursor: 'pointer', textTransform: 'capitalize' }}>
            {t === 'All' ? 'All Types' : t === 'shortlet' ? 'Shortlet' : 'For Rent'}
          </button>
        ))}
      </div>

      {/* Table */}
      <div style={{ background: '#fff', borderRadius: 16, boxShadow: '0 1px 4px rgba(0,0,0,0.06)', border: '1px solid #f3f4f6', overflow: 'hidden' }}>
        <div style={{ overflowX: 'auto' }}>
          <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 13 }}>
            <thead>
              <tr style={{ borderBottom: '1px solid #f3f4f6' }}>
                {['Property', 'Location', 'Type', 'Price', 'Beds/Bath', 'Rating', 'Status', 'Actions'].map(h => (
                  <th key={h} style={{ padding: '12px 16px', textAlign: 'left', fontWeight: 600, color: '#6b7280', fontSize: 11, textTransform: 'uppercase', letterSpacing: '0.5px', whiteSpace: 'nowrap' }}>{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {filtered.map((p, i) => (
                <tr key={p.id} style={{ borderBottom: i < filtered.length - 1 ? '1px solid #f9fafb' : 'none' }}
                  onMouseEnter={e => e.currentTarget.style.background = '#fafafa'}
                  onMouseLeave={e => e.currentTarget.style.background = 'transparent'}
                >
                  <td style={{ padding: '12px 16px' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                      <img src={p.imageUrl} alt="" style={{ width: 44, height: 36, borderRadius: 8, objectFit: 'cover', flexShrink: 0, background: '#f3f4f6' }} />
                      <span style={{ fontWeight: 600, color: '#111', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis', maxWidth: 140 }}>{p.name}</span>
                    </div>
                  </td>
                  <td style={{ padding: '12px 16px', color: '#6b7280', whiteSpace: 'nowrap' }}>{p.location}</td>
                  <td style={{ padding: '12px 16px' }}><Badge label={p.listingType === 'shortlet' ? 'Shortlet' : 'For Rent'} type={p.listingType} /></td>
                  <td style={{ padding: '12px 16px', fontWeight: 600, color: '#111', whiteSpace: 'nowrap' }}>
                    {formatNaira(p.price)}<span style={{ fontWeight: 400, color: '#9ca3af', fontSize: 11 }}>{p.listingType === 'shortlet' ? '/night' : '/mo'}</span>
                  </td>
                  <td style={{ padding: '12px 16px', color: '#374151' }}>{p.bedrooms}bd · {p.bathrooms}ba</td>
                  <td style={{ padding: '12px 16px' }}>
                    <span style={{ display: 'flex', alignItems: 'center', gap: 4, color: '#f59e0b', fontWeight: 600 }}>
                      ★ {p.rating}
                    </span>
                  </td>
                  <td style={{ padding: '12px 16px' }}>
                    <Badge label={p.isActive ? 'Active' : 'Paused'} type={p.isActive ? 'active' : 'suspended'} />
                  </td>
                  <td style={{ padding: '12px 16px' }}>
                    <div style={{ display: 'flex', gap: 6 }}>
                      <button onClick={() => toggleActive(p.id)} title={p.isActive ? 'Pause' : 'Activate'}
                        style={{ padding: '6px', borderRadius: 8, border: '1px solid #e5e7eb', background: '#fff', cursor: 'pointer', display: 'flex', alignItems: 'center', color: p.isActive ? '#f59e0b' : '#10b981' }}>
                        {p.isActive ? <Pause size={13} /> : <Play size={13} />}
                      </button>
                      <button onClick={() => deleteProperty(p.id)} title="Delete"
                        style={{ padding: '6px', borderRadius: 8, border: '1px solid #fee2e2', background: '#fff', cursor: 'pointer', display: 'flex', alignItems: 'center', color: '#ef4444' }}>
                        <Trash2 size={13} />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
              {filtered.length === 0 && (
                <tr><td colSpan={8} style={{ padding: 40, textAlign: 'center', color: '#9ca3af', fontSize: 14 }}>No properties match your filters.</td></tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
