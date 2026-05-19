import { useState } from 'react';
import Sidebar from './components/Sidebar';
import OverviewPage from './pages/OverviewPage';
import PropertiesPage from './pages/PropertiesPage';
import UsersPage from './pages/UsersPage';
import VerificationsPage from './pages/VerificationsPage';
import RequestsPage from './pages/RequestsPage';

export default function App() {
  const [activePage, setActivePage] = useState('overview');
  const [sidebarOpen, setSidebarOpen] = useState(false);

  const pages = {
    overview: <OverviewPage />,
    properties: <PropertiesPage />,
    users: <UsersPage />,
    verifications: <VerificationsPage />,
    requests: <RequestsPage />,
  };

  return (
    <div style={{ display: 'flex', height: '100vh', background: '#f8f9fa', overflow: 'hidden' }}>
      {sidebarOpen && (
        <div
          onClick={() => setSidebarOpen(false)}
          style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.4)', zIndex: 20 }}
          className="lg:hidden"
        />
      )}

      <Sidebar
        activePage={activePage}
        onNavigate={(page) => { setActivePage(page); setSidebarOpen(false); }}
        isOpen={sidebarOpen}
        onClose={() => setSidebarOpen(false)}
      />

      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', overflow: 'hidden', minWidth: 0 }}>
        {/* Mobile topbar */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '12px 16px', background: '#fff', borderBottom: '1px solid #f0f0f0', boxShadow: '0 1px 3px rgba(0,0,0,0.05)' }} className="lg:hidden">
          <button
            onClick={() => setSidebarOpen(true)}
            style={{ padding: 8, borderRadius: 10, background: '#f3f4f6', border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center' }}
          >
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
              <line x1="3" y1="6" x2="21" y2="6" /><line x1="3" y1="12" x2="21" y2="12" /><line x1="3" y1="18" x2="21" y2="18" />
            </svg>
          </button>
          <span style={{ fontWeight: 700, fontSize: 18, letterSpacing: '-0.3px' }}>Rosera Admin</span>
        </div>

        <main style={{ flex: 1, overflowY: 'auto' }}>
          {pages[activePage]}
        </main>
      </div>
    </div>
  );
}
