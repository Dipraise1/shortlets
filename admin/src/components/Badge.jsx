const configs = {
  active:    { bg: '#ecfdf5', color: '#10b981' },
  suspended: { bg: '#fef2f2', color: '#ef4444' },
  pending:   { bg: '#fffbeb', color: '#f59e0b' },
  approved:  { bg: '#ecfdf5', color: '#10b981' },
  rejected:  { bg: '#fef2f2', color: '#ef4444' },
  accepted:  { bg: '#ecfdf5', color: '#10b981' },
  declined:  { bg: '#fef2f2', color: '#ef4444' },
  renter:    { bg: '#eff6ff', color: '#3b82f6' },
  lister:    { bg: '#faf5ff', color: '#8b5cf6' },
  admin:     { bg: '#111', color: '#fff' },
  shortlet:  { bg: '#f0f9ff', color: '#0ea5e9' },
  rent:      { bg: '#fdf4ff', color: '#a855f7' },
};

export default function Badge({ label, type }) {
  const { bg, color } = configs[type] || { bg: '#f3f4f6', color: '#6b7280' };
  return (
    <span style={{
      display: 'inline-flex',
      alignItems: 'center',
      padding: '3px 10px',
      borderRadius: 99,
      fontSize: 11,
      fontWeight: 600,
      background: bg,
      color,
      whiteSpace: 'nowrap',
    }}>
      {label}
    </span>
  );
}
