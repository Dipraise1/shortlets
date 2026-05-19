import { LayoutDashboard, Building2, Users, ShieldCheck, FileText, X, LogOut } from 'lucide-react';
import { verifications, requests } from '../data/mockData';

const navItems = [
  { id: 'overview', label: 'Overview', icon: LayoutDashboard },
  { id: 'properties', label: 'Properties', icon: Building2 },
  { id: 'users', label: 'Users', icon: Users },
  {
    id: 'verifications', label: 'Verifications', icon: ShieldCheck,
    badge: verifications.filter(v => v.status === 'pending').length,
  },
  {
    id: 'requests', label: 'Requests', icon: FileText,
    badge: requests.filter(r => r.status === 'pending').length,
  },
];

export default function Sidebar({ activePage, onNavigate, isOpen, onClose }) {
  return (
    <aside style={{
      width: 240,
      background: '#fff',
      borderRight: '1px solid #f0f0f0',
      display: 'flex',
      flexDirection: 'column',
      flexShrink: 0,
      position: 'fixed',
      top: 0,
      left: isOpen ? 0 : -240,
      height: '100vh',
      zIndex: 30,
      transition: 'left 0.25s ease',
      boxShadow: isOpen ? '4px 0 20px rgba(0,0,0,0.08)' : 'none',
    }}
    // Always visible on desktop (override via JS since we're not using full Tailwind)
    id="sidebar"
    >
      {/* Logo */}
      <div style={{ padding: '24px 20px 20px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
          <div style={{ width: 36, height: 36, background: '#111', borderRadius: 10, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <span style={{ color: '#fff', fontWeight: 800, fontSize: 14, letterSpacing: '-0.5px' }}>R</span>
          </div>
          <div>
            <div style={{ fontWeight: 700, fontSize: 15, letterSpacing: '-0.3px', color: '#111' }}>Rosera</div>
            <div style={{ fontSize: 11, color: '#9ca3af', fontWeight: 500 }}>Admin Panel</div>
          </div>
        </div>
        <button onClick={onClose} style={{ background: 'none', border: 'none', cursor: 'pointer', padding: 4, color: '#6b7280' }} className="lg:hidden">
          <X size={18} />
        </button>
      </div>

      {/* Nav */}
      <nav style={{ flex: 1, padding: '8px 12px', display: 'flex', flexDirection: 'column', gap: 2 }}>
        {navItems.map(({ id, label, icon: Icon, badge }) => {
          const active = activePage === id;
          return (
            <button
              key={id}
              onClick={() => onNavigate(id)}
              style={{
                width: '100%',
                display: 'flex',
                alignItems: 'center',
                gap: 10,
                padding: '10px 12px',
                borderRadius: 10,
                border: 'none',
                cursor: 'pointer',
                background: active ? '#111' : 'transparent',
                color: active ? '#fff' : '#6b7280',
                fontWeight: active ? 600 : 500,
                fontSize: 14,
                transition: 'all 0.15s ease',
                textAlign: 'left',
              }}
              onMouseEnter={e => { if (!active) e.currentTarget.style.background = '#f9fafb'; }}
              onMouseLeave={e => { if (!active) e.currentTarget.style.background = 'transparent'; }}
            >
              <Icon size={17} strokeWidth={active ? 2.5 : 2} />
              <span style={{ flex: 1 }}>{label}</span>
              {badge > 0 && (
                <span style={{
                  background: active ? '#fff' : '#ef4444',
                  color: active ? '#111' : '#fff',
                  fontSize: 10,
                  fontWeight: 700,
                  borderRadius: 99,
                  padding: '1px 7px',
                  minWidth: 18,
                  textAlign: 'center',
                }}>{badge}</span>
              )}
            </button>
          );
        })}
      </nav>

      {/* Footer */}
      <div style={{ padding: '16px 12px', borderTop: '1px solid #f3f4f6' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '10px 12px', borderRadius: 10, background: '#f9fafb', marginBottom: 6 }}>
          <div style={{ width: 32, height: 32, borderRadius: '50%', background: '#111', display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff', fontWeight: 700, fontSize: 13 }}>
            A
          </div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ fontWeight: 600, fontSize: 13, color: '#111', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>Admin</div>
            <div style={{ fontSize: 11, color: '#9ca3af', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>admin@rosera.ng</div>
          </div>
        </div>
        <button style={{ width: '100%', display: 'flex', alignItems: 'center', gap: 8, padding: '8px 12px', borderRadius: 8, border: 'none', cursor: 'pointer', background: 'transparent', color: '#ef4444', fontSize: 13, fontWeight: 500 }}>
          <LogOut size={15} />
          Sign out
        </button>
      </div>

      <style>{`
        @media (min-width: 1024px) {
          #sidebar {
            position: relative !important;
            left: 0 !important;
            box-shadow: none !important;
          }
        }
      `}</style>
    </aside>
  );
}
